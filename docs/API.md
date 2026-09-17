# X86 Pay API Reference

**Status:** local test API
**Base URL:** `http://127.0.0.1:4242/v1`
**Authentication:** `Bearer x86_test_key`

X86 Pay is a bounded, in-memory x86-64 assembly implementation. It is for
local testing only and does not process real payments.

## Resource identifiers

Resource IDs are opaque, boot-scoped UIDs. Capture each ID from the response
that created the resource and pass it unchanged to later requests. The public
formats are:

| Resource | Format |
| --- | --- |
| User | `usr_<16 lowercase hexadecimal characters>` |
| Account | `acct_<16 lowercase hexadecimal characters>` |
| Transaction | `txn_<16 lowercase hexadecimal characters>` |
| Event | `evt_<16 lowercase hexadecimal characters>` |
| PaymentIntent | `pi_<16 lowercase hexadecimal characters>` |

The examples below use synthetic IDs for readability. They are not valid
across server restarts; the current in-memory implementation creates a new UID
namespace at boot and does not persist resources.

## Request conventions

Every request requires:

```http
Authorization: Bearer x86_test_key
```

POST requests with form data require exactly:

```http
Content-Type: application/x-www-form-urlencoded
```

Form fields must be present exactly once. Unknown fields are rejected. Amounts
are positive integers in minor units and are limited to eight digits. Account
money routes currently support `currency=usd` only.

Every response includes a `Request-Id` header. JSON responses also include a
`request_id` field. The request ID identifies the HTTP request and is not a
persistent transaction timestamp.

## Authentication errors

Missing or invalid authentication returns `401`:

```json
{
  "error": {
    "type": "authentication_error",
    "code": "authentication_required",
    "message": "authentication required",
    "request_id": "req_x86_1"
  }
}
```

## Error envelope

Application errors use this shape:

```json
{
  "error": {
    "type": "invalid_request_error",
    "code": "invalid_request",
    "message": "missing required field: email",
    "request_id": "req_x86_2"
  }
}
```

Common statuses are `400` invalid request, `401` authentication failure,
`402` insufficient funds, `404` missing resource, `409` conflict, `413` request
too large, and `507` bounded table capacity exhausted.

The stable error contract is:

| Status | `type` | `code` | Typical `message` |
| --- | --- | --- | --- |
| 400 | `invalid_request_error` | `invalid_request` | `invalid request`, `missing required field: ...`, `currency must be usd`, or a route-specific validation message |
| 400 | `idempotency_error` | `idempotency_key_in_use` | `idempotency key reused with different parameters` |
| 401 | `authentication_error` | `authentication_required` | `authentication required` |
| 402 | `invalid_request_error` | `insufficient_funds` | `insufficient funds` |
| 404 | `invalid_request_error` | `resource_not_found` | `resource not found`, `transaction not found`, or `event not found` |
| 409 | `invalid_request_error` | `invalid_request` | `email already taken` |
| 413 | `invalid_request_error` | `request_too_large` | `request body too large` |
| 507 | `api_error` | `idempotency_table_full` | `idempotency table full` |
| 507 | `invalid_request_error` | `invalid_request` | `table full` |

Every error also includes `request_id`, and the same value is returned in the
`Request-Id` header. Capacity errors are returned before state mutation. The
`idempotency_table_full` variant applies to the keyed table for the route;
the `table full` variant applies to bounded users, accounts, transactions, and
events.

## Users

### Create a user

```http
POST /v1/users
Content-Type: application/x-www-form-urlencoded

email=alice@example.com
```

Response: `201 Created`

```json
{
  "id": "usr_7b4e2d1c9a806f01",
  "object": "user",
  "email": "alice@example.com",
  "request_id": "req_x86_3"
}
```

Email values are stored as opaque strings up to the server field limit. Email
uniqueness is enforced.

## Accounts

### Open an account

```http
POST /v1/accounts
Content-Type: application/x-www-form-urlencoded

user_id=usr_7b4e2d1c9a806f01&currency=usd
```

Response: `201 Created`

```json
{
  "id": "acct_7b4e2d1c9a806f01",
  "object": "account",
  "user_id": "usr_7b4e2d1c9a806f01",
  "currency": "usd",
  "balance": 0,
  "request_id": "req_x86_4"
}
```

### Retrieve an account

```http
GET /v1/accounts/acct_7b4e2d1c9a806f01
```

### Retrieve a balance

```http
GET /v1/accounts/acct_7b4e2d1c9a806f01/balance
```

Response:

```json
{
  "balance": 5000,
  "request_id": "req_x86_5"
}
```

## Deposits

```http
POST /v1/accounts/acct_7b4e2d1c9a806f01/deposit
Content-Type: application/x-www-form-urlencoded

amount=5000&currency=usd
```

Response: `200 OK`

```json
{
  "id": "txn_7b4e2d1c9a806f03",
  "object": "transaction",
  "account_id": "acct_7b4e2d1c9a806f01",
  "amount": 5000,
  "type": "deposit",
  "request_id": "req_x86_6"
}
```

## Sending money

```http
POST /v1/accounts/acct_7b4e2d1c9a806f01/send
Content-Type: application/x-www-form-urlencoded

to_account_id=acct_7b4e2d1c9a806f02&amount=1000&currency=usd
```

Response:

```json
{
  "id": "txn_7b4e2d1c9a806f04",
  "object": "transaction",
  "sender_id": "acct_7b4e2d1c9a806f01",
  "recipient_id": "acct_7b4e2d1c9a806f02",
  "amount": 1000,
  "type": "transfer",
  "request_id": "req_x86_7"
}
```

Self-transfers are rejected. Insufficient funds return `402` and do not change
either balance or append a ledger entry.

## Withdrawals

```http
POST /v1/accounts/acct_7b4e2d1c9a806f01/withdraw
Content-Type: application/x-www-form-urlencoded

amount=250&currency=usd
```

The response is a transaction with `type` equal to `withdrawal`.

## Transactions and reversals

Retrieve a transaction by ID:

```http
GET /v1/transactions/txn_7b4e2d1c9a806f04
```

Transaction types are:

| Type | Meaning | Reversible |
|---|---|---|
| `account_opened` | Account creation ledger entry | No |
| `deposit` | Funds credited to an account | Yes, if the account can cover the debit |
| `transfer` | Account-to-account send | Yes, if the recipient can cover the debit |
| `withdrawal` | Funds removed from an account | Yes |
| `reversal` | Compensating entry | No |

Reverse an eligible transaction:

```http
POST /v1/transactions/txn_7b4e2d1c9a806f04/reverse
Authorization: Bearer x86_test_key
```

The operation is atomic. A transaction cannot be reversed twice.

## Events

List the bounded event stream:

```http
GET /v1/events
```

Response:

```json
{
  "object": "list",
  "data": [
    {
      "id": "evt_7b4e2d1c9a806f01",
      "object": "event",
      "type": "deposit.created",
      "transaction_id": "txn_7b4e2d1c9a806f03",
      "amount": 5000,
      "currency": "usd"
    }
  ],
  "request_id": "req_x86_8"
}
```

Retrieve one event with `GET /v1/events/evt_7b4e2d1c9a806f01`.

## PaymentIntents

PaymentIntents remain available as the original prototype resource:

```http
POST /v1/payment_intents
Content-Type: application/x-www-form-urlencoded
Idempotency-Key: checkout-1

amount=2000&currency=usd
```

The response has the form:

```json
{
  "id": "pi_7b4e2d1c9a806f01",
  "object": "payment_intent",
  "amount": 2000,
  "currency": "usd",
  "status": "requires_payment_method",
  "request_id": "req_x86_9"
}
```

Repeating the same idempotency key with the same parameters replays the
original response. Reusing it with different parameters returns an
idempotency error. The key is scoped to the route and the money-movement
account context, so a key cannot silently replay a transfer for another
account or recipient.

Deposit, send, and withdraw requests support the same behavior:

```http
POST /v1/accounts/acct_7b4e2d1c9a806f01/deposit
Idempotency-Key: deposit-1
Content-Type: application/x-www-form-urlencoded

amount=5000&currency=usd
```

Retries replay the original transaction response without changing balances or
consuming another transaction/event slot. Failed requests are not stored as
successful idempotency records.

Retrieve a PaymentIntent with:

```http
GET /v1/payment_intents/pi_7b4e2d1c9a806f01
```

## Capacity and persistence

The current process uses fixed in-memory tables:

- 16 users
- 16 accounts
- 16 transactions
- 16 events
- 8 stored PaymentIntent idempotency keys
- 8 stored idempotency keys per money route (deposit, send, and withdraw)

Capacity failures return `507`. A rejected capacity request does not mutate the
associated account, balance, transaction, or event state. All tables are
process-local; restarting the server clears all state.
