#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/x86pay-test.XXXXXX")
SERVER_PID=

cleanup() {
    status=$?
    if [ -n "$SERVER_PID" ]; then
        kill "$SERVER_PID" 2>/dev/null || true
        wait "$SERVER_PID" 2>/dev/null || true
    fi
    rm -rf "$TMP_DIR"
    exit "$status"
}

trap cleanup EXIT INT TERM

cd "$ROOT_DIR"

./build/x86pay_server >"$TMP_DIR/server.log" 2>&1 &
SERVER_PID=$!

attempt=0
while [ "$attempt" -lt 50 ]; do
    if curl -sS --connect-timeout 0.1 --max-time 0.2 \
        -o /dev/null "http://127.0.0.1:4242/nope"; then
        break
    fi

    if ! kill -0 "$SERVER_PID" 2>/dev/null; then
        printf '%s\n' 'server exited before becoming ready' >&2
        cat "$TMP_DIR/server.log" >&2
        exit 1
    fi

    attempt=$((attempt + 1))
    sleep 0.02
done

if [ "$attempt" -ge 50 ]; then
    printf '%s\n' 'server did not become ready' >&2
    cat "$TMP_DIR/server.log" >&2
    exit 1
fi

request() {
    curl -sS --connect-timeout 1 --max-time 2 \
        -D "$TMP_DIR/headers" \
        -o "$TMP_DIR/body" \
        "$@"
}

status_code() {
    awk 'NR == 1 { print $2; exit }' "$TMP_DIR/headers"
}

assert_status() {
    expected=$1
    actual=$(status_code)
    if [ "$actual" != "$expected" ]; then
        printf 'expected HTTP %s, got HTTP %s\n' "$expected" "$actual" >&2
        cat "$TMP_DIR/body" >&2
        exit 1
    fi
}

assert_body_contains() {
    if ! grep -Fq -- "$1" "$TMP_DIR/body"; then
        printf 'response did not contain: %s\n' "$1" >&2
        cat "$TMP_DIR/body" >&2
        exit 1
    fi
}

./build/x86pay_client 2000 usd >"$TMP_DIR/client.out"
grep -Fq 'HTTP/1.1 200 OK' "$TMP_DIR/client.out"
grep -Fq '"id":"pi_x86_1"' "$TMP_DIR/client.out"
printf '%s\n' 'ok - assembly client creates a PaymentIntent'

request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/payment_intents/pi_x86_1'
assert_status 200
assert_body_contains '"id":"pi_x86_1"'
printf '%s\n' 'ok - PaymentIntent retrieval'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Idempotency-Key: integration-key-1' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=3000&currency=eur' \
    'http://127.0.0.1:4242/v1/payment_intents'
assert_status 200
assert_body_contains '"id":"pi_x86_2"'
assert_body_contains '"amount":3000'
printf '%s\n' 'ok - PaymentIntent creation'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Idempotency-Key: integration-key-1' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=3000&currency=eur' \
    'http://127.0.0.1:4242/v1/payment_intents'
assert_status 200
assert_body_contains '"id":"pi_x86_2"'
printf '%s\n' 'ok - idempotency replay'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Idempotency-Key: integration-key-1' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=3500&currency=eur' \
    'http://127.0.0.1:4242/v1/payment_intents'
assert_status 400
assert_body_contains 'idempotency key reused with different parameters'
printf '%s\n' 'ok - idempotency conflict'

request \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=100&currency=usd' \
    'http://127.0.0.1:4242/v1/payment_intents'
assert_status 401
assert_body_contains 'authentication required'
printf '%s\n' 'ok - authentication failure'

request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/nope'
assert_status 404
assert_body_contains 'resource not found'
printf '%s\n' 'ok - unknown route'

printf '%s\n' 'all integration tests passed'
