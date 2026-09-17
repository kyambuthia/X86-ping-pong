# X86 Pay — Wallet API Reference

**Version**: Planned
**Base URL**: `http://127.0.0.1:4242/v1`
**Authentication**: Bearer token (see [Authentication](#authentication))

This document defines the complete planned wallet API for X86 Pay. The API is
resource-oriented, uses form-encoded requests and JSON responses, and follows
the conventions of Stripe's REST API. All money values are expressed as
**integer minor units** (e.g., `2000` means 2000 cents, or $20.00 in USD).

The current prototype implements only PaymentIntents. The wallet API described
here is the planned target and serves as the specification the implementation
will grow toward.

---

## Authentication

All API requests must include an `Authorization` header with a Bearer token:

```
Authorization: Bearer x86_test_key
```

The test key is `x86_test_key`. Requests missing or using an invalid key
receive a `401 Unauthorized` response.

```
POST /v1/wallets HTTP/1.1
Authorization: Bearer x86_test_key
Content-Type: application/x-www-form-urlencoded
```

Errors are returned as JSON:

```json
{"error":{"message":"authentication required"}}
```

---

## Core verbs

The wallet API uses six simple verbs. Every endpoint is under `/v1/`.

| Verb     | Endpoint                        | Description                    |
|----------|---------------------------------|--------------------------------|
| `open`   | `POST /v1/wallets`              | Create a new wallet            |
| `deposit`| `POST /v1/wallets/{id}/deposit` | Add funds to a wallet          |
| `check`  | `GET /v1/wallets/{id}/balance`  | Read the current balance       |
| `send`   | `POST /v1/wallets/{id}/send`    | Transfer funds to another user |
| `withdraw`| `POST /v1/wallets/{id}/withdraw`| Remove funds from a wallet     |
| `reverse`| `POST /v1/transactions/{id}/reverse` | Reverse a completed transaction |

---

## 1. Users and authentication

### Who can use the API

Every caller presents a Bearer token. The server recognizes one test key,
`x86_test_key`. In production, each user would have their own key pair
(publishable and secret). This prototype has no user registration endpoint;
the API key is the identity.

### Security boundary

This is a **test-only** API. It has no TLS, no password hashing, no multi-user
authorization model, and no fraud controls. Never send real credentials or
real customer data to this server.

---

## 2. Accounts (wallets)

A **wallet** is a user's account that holds a balance. Every wallet has a
unique ID (`wl_x86_<number>`), a currency, and a balance stored in integer
minor units.

### Create a wallet (`open`)

```
POST /v1/wallets
Authorization: Bearer x86_test_key
Content-Type: application/x-www-form-urlencoded

currency=usd
```

**Request fields**

| Field     | Type   | Required | Description                    |
|-----------|--------|----------|--------------------------------|
| `currency`| string | yes      | Three-letter ISO code (`usd`, `eur`) |

**Response** `201 Created`

```json
{
  "id": "wl_x86_1",
  "object": "wallet",
  "currency": "usd",
  "balance": 0,
  "status": "open",
  "created": 1700000000
}
```

**Errors**

| Code | Body                                                        | When                                  |
|------|-------------------------------------------------------------|---------------------------------------|
| 400  | `{"error":{"message":"invalid request"}}`                   | Missing or invalid currency            |
| 401  | `{"error":{"message":"authentication required"}}`           | Missing or invalid Bearer token        |

### Retrieve a wallet (`check`)

```
GET /v1/wallets/{wallet_id}
Authorization: Bearer x86_test_key
```

**Response** `200 OK`

```json
{
  "id": "wl_x86_1",
  "object": "wallet",
  "currency": "usd",
  "balance": 2000,
  "status": "open",
  "created": 1700000000
}
```

---

## 3. Money values

All monetary amounts in requests and responses are **integers in the smallest
unit of the currency** (minor units). For USD, the minor unit is cents:

| Display  | API value |
|----------|-----------|
| $1.00    | `100`     |
| $20.00   | `2000`    |
| $0.50    | `50`      |
| $100.00  | `10000`   |

Never send decimal values. The server rejects non-integer amounts.

---

## 4. Deposit

Add funds to an open wallet.

```
POST /v1/wallets/{wallet_id}/deposit
Authorization: Bearer x86_test_key
Content-Type: application/x-www-form-urlencoded

amount=5000&currency=usd
```

**Request fields**

| Field     | Type   | Required | Description                          |
|-----------|--------|----------|--------------------------------------|
| `amount`  | integer| yes      | Positive integer in minor units      |
| `currency`| string | yes      | Must match the wallet's currency     |

**Response** `200 OK`

```json
{
  "id": "dp_x86_1",
  "object": "deposit",
  "wallet_id": "wl_x86_1",
  "amount": 5000,
  "currency": "usd",
  "status": "completed",
  "created": 1700000000
}
```

**Errors**

| Code | Body                                                        | When                                  |
|------|-------------------------------------------------------------|---------------------------------------|
| 400  | `{"error":{"message":"invalid request"}}`                   | Missing/invalid amount, currency mismatch |
| 401  | `{"error":{"message":"authentication required"}}`           | Missing or invalid Bearer token        |
| 404  | `{"error":{"message":"resource not found"}}`                | Wallet does not exist                  |
| 413  | `{"error":{"message":"request body too large"}}`            | Request body exceeds limit             |

---

## 5. Check balance

Read the current balance of a wallet.

```
GET /v1/wallets/{wallet_id}/balance
Authorization: Bearer x86_test_key
```

**Response** `200 OK`

```json
{
  "wallet_id": "wl_x86_1",
  "currency": "usd",
  "balance": 5000,
  "object": "balance"
}
```

**Errors**

| Code | Body                                                        | When                                  |
|------|-------------------------------------------------------------|---------------------------------------|
| 401  | `{"error":{"message":"authentication required"}}`           | Missing or invalid Bearer token        |
| 404  | `{"error":{"message":"resource not found"}}`                | Wallet does not exist                  |

---

## 6. Send

Transfer funds from one wallet to another user's wallet. The **recipient is
automatically credited** — this is atomic in the sense that the sender's
balance is debited only if the recipient can be credited.

```
POST /v1/wallets/{wallet_id}/send
Authorization: Bearer x86_test_key
Content-Type: application/x-www-form-urlencoded

amount=1000&currency=usd&recipient=wl_x86_2
```

**Request fields**

| Field       | Type   | Required | Description                                    |
|-------------|--------|----------|------------------------------------------------|
| `amount`    | integer| yes      | Positive integer in minor units                |
| `currency`  | string | yes      | Must match the sender's wallet currency          |
| `recipient` | string | yes      | The recipient's wallet ID (`wl_x86_<number>`)   |

**Response** `200 OK`

```json
{
  "id": "tx_x86_1",
  "object": "transaction",
  "sender_id": "wl_x86_1",
  "recipient_id": "wl_x86_2",
  "amount": 1000,
  "currency": "usd",
  "status": "completed",
  "created": 1700000000
}
```

**Automatic recipient credit / receive semantics**

When a send completes:

1. The sender's wallet balance is checked — it must be >= `amount`.
2. The sender is debited by `amount`.
3. The recipient's wallet is credited by `amount` **automatically**.
4. Both sides are updated atomically: either both succeed or neither does.
5. A transaction record is created with `status: "completed"`.

The recipient does not need to take any action. The credit is immediate and
automatic upon the sender's send succeeding.

**Errors**

| Code | Body                                                        | When                                       |
|------|-------------------------------------------------------------|--------------------------------------------|
| 400  | `{"error":{"message":"invalid request"}}`                   | Missing fields, non-positive amount, currency mismatch |
| 401  | `{"error":{"message":"authentication required"}}`           | Missing or invalid Bearer token             |
| 404  | `{"error":{"message":"resource not found"}}`                | Sender or recipient wallet does not exist    |
| 402  | `{"error":{"message":"insufficient funds"}}`                | Sender balance < amount (planned)            |

---

## 7. Withdraw

Remove funds from a wallet. Funds leave the system entirely.

```
POST /v1/wallets/{wallet_id}/withdraw
Authorization: Bearer x86_test_key
Content-Type: application/x-www-form-urlencoded

amount=2000&currency=usd
```

**Request fields**

| Field     | Type   | Required | Description                          |
|-----------|--------|----------|--------------------------------------|
| `amount`  | integer| yes      | Positive integer in minor units      |
| `currency`| string | yes      | Must match the wallet's currency     |

**Response** `200 OK`

```json
{
  "id": "wd_x86_1",
  "object": "withdrawal",
  "wallet_id": "wl_x86_1",
  "amount": 2000,
  "currency": "usd",
  "status": "completed",
  "created": 1700000000
}
```

**Errors**

| Code | Body                                                        | When                                  |
|------|-------------------------------------------------------------|---------------------------------------|
| 400  | `{"error":{"message":"invalid request"}}`                   | Missing/invalid amount                |
| 401  | `{"error":{"message":"authentication required"}}`           | Missing or invalid Bearer token        |
| 404  | `{"error":{"message":"resource not found"}}`                | Wallet does not exist                  |
| 402  | `{"error":{"message":"insufficient funds"}}`                | Balance < amount (planned)             |

---

## 8. Reverse

Reverse a completed transaction. This refunds the amount back to the
original sender.

```
POST /v1/transactions/{transaction_id}/reverse
Authorization: Bearer x86_test_key
```

**Request fields**: None.

**Response** `200 OK`

```json
{
  "id": "rev_x86_1",
  "object": "reversal",
  "transaction_id": "tx_x86_1",
  "amount": 1000,
  "currency": "usd",
  "status": "completed",
  "created": 1700000000
}
```

**Rules for reversal**

- Only a transaction with `status: "completed"` can be reversed.
- Reversal credits the original sender and debits the original recipient.
- The reversal amount equals the original transaction amount.
- A reversal creates a new transaction record linked to the original.

**Errors**

| Code | Body                                                        | When                                        |
|------|-------------------------------------------------------------|---------------------------------------------|
| 400  | `{"error":{"message":"invalid request"}}`                   | Transaction already reversed                 |
| 401  | `{"error":{"message":"authentication required"}}`           | Missing or invalid Bearer token               |
| 404  | `{"error":{"message":"resource not found"}}`                | Transaction does not exist                    |

---

## 9. Transactions

Every financial movement creates an immutable **transaction** record.

### Transaction object

```json
{
  "id": "tx_x86_1",
  "object": "transaction",
  "sender_id": "wl_x86_1",
  "recipient_id": "wl_x86_2",
  "amount": 1000,
  "currency": "usd",
  "status": "completed",
  "created": 1700000000
}
```

### Retrieve a transaction

```
GET /v1/transactions/{transaction_id}
Authorization: Bearer x86_test_key
```

**Response** `200 OK`

```json
{
  "id": "tx_x86_1",
  "object": "transaction",
  "sender_id": "wl_x86_1",
  "recipient_id": "wl_x86_2",
  "amount": 1000,
  "currency": "usd",
  "status": "completed",
  "created": 1700000000
}
```

### Immutable transactions

Transaction records are **immutable once created**. Fields such as `amount`,
`currency`, `sender_id`, `recipient_id`, and `created` cannot change. The
only state change is `status` transitions (see [State transitions](#10-state-transitions)).

A reversal does not modify the original transaction; it creates a new
reversal record that references the original transaction ID.

### List transactions

```
GET /v1/transactions
Authorization: Bearer x86_test_key
```

**Response** `200 OK`

```json
{
  "object": "list",
  "data": [
    {
      "id": "tx_x86_1",
      "object": "transaction",
      "sender_id": "wl_x86_1",
      "recipient_id": "wl_x86_2",
      "amount": 1000,
      "currency": "usd",
      "status": "completed",
      "created": 1700000000
    }
  ]
}
```

---

## 10. Resource and state transitions

### Wallet lifecycle

```
closed → open
open   → closed  (via withdraw that empties the wallet)
```

| State   | Meaning                                      |
|---------|----------------------------------------------|
| `closed`| Wallet exists but has no activity; new wallets start here |
| `open`  | Wallet is active and can receive deposits, sends, withdrawals |

A wallet transitions from `closed` to `open` on its first deposit. A wallet
may transition back to `closed` if its balance reaches zero and all
transactions are settled (this is a planned feature).

### Transaction lifecycle

```
pending → completed
pending → failed
completed → reversed
```

| Status      | Meaning                                                |
|-------------|--------------------------------------------------------|
| `pending`   | Transaction is being processed                         |
| `completed` | Transaction succeeded; funds have moved                |
| `failed`    | Transaction did not succeed; no funds moved            |
| `reversed`  | A completed transaction has been reversed              |

---

## 11. Idempotency

The API supports **idempotent requests** via the `Idempotency-Key` header.

```
POST /v1/wallets
Authorization: Bearer x86_test_key
Idempotency-Key: my-unique-key-123
Content-Type: application/x-www-form-urlencoded

currency=usd
```

### How it works

- If a request with a given idempotency key succeeds, repeating the same
  request with the **same key and identical parameters** returns the **same
  response** (the original response, not a new resource).
- If the same idempotency key is used with **different parameters**, the
  server returns `400` with an idempotency conflict error.
- Idempotency keys are scoped to the API key and endpoint.

**Idempotency conflict error**:

```json
{"error":{"message":"idempotency key reused with different parameters"}}
```

### Best practices

- Generate a unique idempotency key for each logical operation.
- Retry safely on network failures using the same key.
- Keep idempotency keys unique across different operations (even if they
  hit the same endpoint).

---

## 12. Events and webhooks

The API can emit **events** to registered webhook endpoints when significant
things happen.

### Event types

| Event                 | Triggered when                          |
|-----------------------|-----------------------------------------|
| `wallet.created`      | A new wallet is opened                  |
| `wallet.balance_changed` | Deposit, send, withdraw, or reversal changes balance |
| `transaction.completed` | A send or deposit completes            |
| `transaction.reversed` | A completed transaction is reversed     |
| `transaction.failed`  | A transaction fails                     |

### Webhook payload

Events are sent as HTTP POST requests to the registered URL with a JSON
body:

```json
{
  "event": "transaction.completed",
  "id": "evt_x86_1",
  "created": 1700000000,
  "data": {
    "id": "tx_x86_1",
    "object": "transaction",
    "sender_id": "wl_x86_1",
    "recipient_id": "wl_x86_2",
    "amount": 1000,
    "currency": "usd",
    "status": "completed"
  }
}
```

### Webhook configuration

Webhook URLs are configured per API key. In this prototype, webhooks are
simulated and logged; no real HTTP calls are made.

**Important**: Webhook delivery is **not guaranteed**. Your webhook endpoint
must be idempotent — the same event may be delivered more than once.

---

## 13. Ledger invariants

The wallet system maintains the following **invariants** at all times:

1. **Conservation of money**: The sum of all wallet balances across the
   system never changes except through deposits (increase) and withdrawals
   (decrease). Sends do not change the total — they only move money between
   wallets.

2. **No negative balances**: A wallet's balance must never be negative.
   Deposits, sends, and withdrawals that would cause a negative balance are
   rejected.

3. **Transaction completeness**: Every debit has a corresponding credit.
   For every transaction, `sender_balance_after = sender_balance_before - amount`
   and `recipient_balance_after = recipient_balance_before + amount`.

4. **Immutability of records**: Once a transaction is created, its data
   cannot be altered. Reversals create new records, never modify old ones.

5. **Idempotency consistency**: A replayed idempotent request never creates
   a new resource or changes a balance.

These invariants are enforced by the server before committing any state
change.

---

## 14. Errors

All errors are returned as JSON with the appropriate HTTP status code:

```json
{"error":{"message":"<message>"}}
```

### Error codes

| Status | Body message                              | When                                          |
|--------|-------------------------------------------|-----------------------------------------------|
| 400    | `invalid request`                         | Missing/invalid fields, malformed input         |
| 400    | `idempotency key reused with different parameters` | Same key, different params           |
| 401    | `authentication required`                 | Missing or invalid Bearer token                |
| 402    | `insufficient funds`                      | Balance less than requested amount             |
| 404    | `resource not found`                      | Wallet, transaction, or event not found         |
| 413    | `request body too large`                  | Request body exceeds 8192 bytes                |

### Request validation rules

- `amount` must be a positive integer (no decimals, no zero, no negatives).
- `currency` must be a three-letter lowercase ISO code.
- Form bodies must use `application/x-www-form-urlencoded` content type.
- Unknown form fields are rejected.
- Duplicate form fields are rejected.
- Maximum request body size is 8192 bytes.

---

## 15. Test-only boundary

This API is explicitly a **test-only prototype**. The following boundaries
apply:

- **No real money**: All balances are in-memory integers. No bank accounts,
  no card networks, no real payment processing.
- **No TLS**: Traffic is plaintext HTTP on loopback only.
- **No durable storage**: All data lives in memory. Restarting the server
  loses all wallets, balances, and transactions.
- **No concurrent control**: The prototype handles one connection at a time.
  This is not safe for production concurrency.
- **No fraud controls**: There is no risk scoring, no velocity checking, no
  account review.
- **No authorization model**: The single test key grants full access. There
  is no concept of user roles or permissions.
- **No webhook delivery**: Events are simulated; no real HTTP calls are made
  to webhook URLs.
- **No compliance**: This does not satisfy PCI DSS, KYC, AML, or any other
  regulatory requirement.

**Never** use this API with real payment credentials or real customer data.

---

## Appendix: Complete example flow

### Opening a wallet and funding it

```sh
# Open a wallet
curl http://127.0.0.1:4242/v1/wallets \
  -H 'Authorization: Bearer x86_test_key' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'currency=usd'
# => {"id":"wl_x86_1","object":"wallet","currency":"usd","balance":0,"status":"open",...}

# Deposit funds
curl http://127.0.0.1:4242/v1/wallets/wl_x86_1/deposit \
  -H 'Authorization: Bearer x86_test_key' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'amount=5000&currency=usd'
# => {"id":"dp_x86_1","object":"deposit","wallet_id":"wl_x86_1","amount":5000,...}

# Check balance
curl http://127.0.0.1:4242/v1/wallets/wl_x86_1/balance \
  -H 'Authorization: Bearer x86_test_key'
# => {"wallet_id":"wl_x86_1","currency":"usd","balance":5000,"object":"balance"}
```

### Sending money to another user

```sh
# User B opens a wallet
curl http://127.0.0.1:4242/v1/wallets \
  -H 'Authorization: Bearer x86_test_key' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'currency=usd'
# => {"id":"wl_x86_2","object":"wallet","currency":"usd","balance":0,...}

# User A sends 1000 cents to User B
curl http://127.0.0.1:4242/v1/wallets/wl_x86_1/send \
  -H 'Authorization: Bearer x86_test_key' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'amount=1000&currency=usd&recipient=wl_x86_2'
# => {"id":"tx_x86_1","object":"transaction","sender_id":"wl_x86_1","recipient_id":"wl_x86_2","amount":1000,...}

# Both balances updated automatically
curl http://127.0.0.1:4242/v1/wallets/wl_x86_1/balance ...
# => {"wallet_id":"wl_x86_1","currency":"usd","balance":4000,...}
curl http://127.0.0.1:4242/v1/wallets/wl_x86_2/balance ...
# => {"wallet_id":"wl_x86_2","currency":"usd","balance":1000,...}
```

### Reversing a transaction

```sh
curl -X POST http://127.0.0.1:4242/v1/transactions/tx_x86_1/reverse \
  -H 'Authorization: Bearer x86_test_key'
# => {"id":"rev_x86_1","object":"reversal","transaction_id":"tx_x86_1","amount":1000,...}
```

---

## Design reference

The API shape follows the broad conventions documented by Stripe:

- [Stripe API reference](https://docs.stripe.com/api)
- [Stripe PaymentIntents](https://docs.stripe.com/api/payment_intents)
- [Stripe idempotent requests](https://docs.stripe.com/api/idempotent_requests)
- [Stripe authentication](https://docs.stripe.com/api/authentication)

## Planned roadmap

1. Add a proper HTTP parser, structured errors, and request IDs.
2. Add more wallet transitions and a full ledger implementation.
3. Add durable storage and concurrent connection handling.
4. Add an explicit test mode and a separate storage boundary before
   considering any external integration.

## License

No license has been selected yet.
