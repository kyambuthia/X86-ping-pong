# X86 Pay

A small, test-only payment API server and client written in x86-64 Linux
assembly. The project takes inspiration from the shape of Stripe's REST API,
but it is an independent local implementation and does not process real
payments.

The first resource is a simplified `PaymentIntent`. The goal is to learn how
an API server handles sockets, HTTP, authentication, resource state, and safe
retries when every layer is built close to the machine.

## Current slice

The server currently supports:

- `POST /v1/payment_intents`
- `GET /v1/payment_intents/pi_x86_<number>`
- Bearer authentication with the local test key `x86_test_key`
- Form-encoded `amount` and `currency` fields
- JSON responses with a Stripe-inspired `PaymentIntent` shape
- A small in-memory idempotency-key replay path

The bundled client creates a PaymentIntent against `127.0.0.1:4242`. The
amount and currency can be supplied as arguments:

```sh
./build/x86pay_client 2000 usd
```

## Build and run

This is currently targeted at x86-64 Linux and uses GNU `as` and `ld` with
direct Linux system calls. No libc or third-party runtime is required.

```sh
make
./build/x86pay_server
```

In another terminal:

```sh
./build/x86pay_client 2000 usd
```

The server listens only on loopback and keeps data in memory. Stop it with
`Ctrl-C`.

You can also exercise the API with `curl`:

```sh
curl http://127.0.0.1:4242/v1/payment_intents \
  -H 'Authorization: Bearer x86_test_key' \
  -H 'Idempotency-Key: curl-demo-1' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'amount=2000&currency=usd'
```

## Safety boundary

This is a learning implementation, not a payment processor. It has no card
handling, TLS, durable storage, webhooks, authorization model, concurrency
control, fraud controls, accounting guarantees, or connection to a bank or
payment network. Never send live payment credentials or real customer data to
it.

## Design reference

The API shape follows the broad conventions documented by Stripe: resource-
oriented HTTP endpoints, form-encoded requests, JSON responses, API-key
authentication, PaymentIntent lifecycle resources, and idempotency keys.

- [Stripe API reference](https://docs.stripe.com/api)
- [Stripe PaymentIntents](https://docs.stripe.com/api/payment_intents)
- [Stripe idempotent requests](https://docs.stripe.com/api/idempotent_requests)
- [Stripe authentication](https://docs.stripe.com/api/authentication)

## Planned roadmap

1. Make request reads length-aware instead of assuming one complete request per
   connection.
2. Add a proper HTTP parser, structured errors, and request IDs.
3. Add more PaymentIntent transitions such as confirm and cancel.
4. Add durable storage and concurrent connection handling.
5. Add an explicit test mode and a separate storage boundary before considering
   any external integration.

## License

No license has been selected yet.
