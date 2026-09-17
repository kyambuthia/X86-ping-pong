# X86 Pay

X86 Pay is a test-only payment API server and client written in x86-64 Linux
assembly. It provides a small, Stripe-inspired HTTP API for users, accounts,
money movement, transactions, events, and PaymentIntents.

It does not process real payments. Data is held in bounded in-memory tables and
is lost when the server stops.

## Current API

The canonical account flow is:

1. Create a user with `POST /v1/users`.
2. Open a USD account with `POST /v1/accounts`.
3. Deposit funds into the account.
4. Send, withdraw, retrieve balances, or reverse eligible transactions.

Supported routes:

```text
POST /v1/users
POST /v1/accounts
GET  /v1/accounts/{account_uid}
GET  /v1/accounts/{account_uid}/balance
POST /v1/accounts/{account_uid}/deposit
POST /v1/accounts/{account_uid}/send
POST /v1/accounts/{account_uid}/withdraw
GET  /v1/transactions/{transaction_uid}
POST /v1/transactions/{transaction_uid}/reverse
GET  /v1/events
GET  /v1/events/{event_uid}
POST /v1/payment_intents
GET  /v1/payment_intents/{payment_intent_uid}
```

All requests require:

```text
Authorization: Bearer x86_test_key
```

Form POST requests require:

```text
Content-Type: application/x-www-form-urlencoded
```

See [`docs/API.md`](docs/API.md) for request fields, response shapes, errors,
capacity limits, and lifecycle examples.

Resource identifiers are opaque, boot-scoped UIDs. The server emits a
16-character lowercase hexadecimal token with a resource prefix:

```text
usr_<16 hex characters>   user
acct_<16 hex characters>  account
txn_<16 hex characters>   transaction
evt_<16 hex characters>   event
pi_<16 hex characters>    PaymentIntent
```

Treat IDs as opaque strings: capture them from responses and pass them back to
later requests. They are intentionally not sequential, and the current
in-memory server generates a new UID namespace on each restart.

## Build and run

This targets x86-64 Linux and uses GNU `as` through `gcc` plus `ld`. The
server and client use direct Linux system calls and do not require libc or
third-party runtime dependencies.

```sh
make
./build/x86pay_server
```

The server listens on `127.0.0.1:4242`.

Run the clean integration suite:

```sh
make test
```

The suite starts its own server and exercises the full account and ledger flow.

## Quickstart

```sh
base=http://127.0.0.1:4242
key='Authorization: Bearer x86_test_key'
form='Content-Type: application/x-www-form-urlencoded'

user_json=$(curl -sS -X POST "$base/v1/users" \
  -H "$key" -H "$form" \
  -d 'email=alice@example.com')
user_id=$(printf '%s' "$user_json" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')

account_json=$(curl -sS -X POST "$base/v1/accounts" \
  -H "$key" -H "$form" \
  -d "user_id=$user_id&currency=usd")
account_id=$(printf '%s' "$account_json" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')

curl -sS -X POST "$base/v1/accounts/$account_id/deposit" \
  -H "$key" -H "$form" \
  -d 'amount=5000&currency=usd'

curl -sS "$base/v1/accounts/$account_id/balance" \
  -H "$key"
```

Amounts are positive integers in minor units. The current account API supports
`usd` only.

The bundled assembly client creates a PaymentIntent:

```sh
./build/x86pay_client 2000 usd
```

## Safety boundary

This is a learning implementation, not a payment processor. It has no TLS,
durable storage, concurrency control, multi-user authorization model, fraud
controls, accounting guarantees, card handling, webhooks, or connection to a
bank or payment network. Never send live payment credentials or real customer
data to it.

## Design reference

The API borrows broad conventions from Stripe: resource-oriented routes,
form-encoded requests, JSON responses, API-key authentication, PaymentIntent
resources, and idempotency keys. It is an independent local implementation.

## License

No license has been selected yet.
