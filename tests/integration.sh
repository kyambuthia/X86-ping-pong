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

assert_header_contains() {
    if ! grep -Fq -- "$1" "$TMP_DIR/headers"; then
        printf 'response header did not contain: %s\n' "$1" >&2
        cat "$TMP_DIR/headers" >&2
        exit 1
    fi
}

raw_request() {
    python3 - "$@" <<'PY' >"$TMP_DIR/raw.resp"
import socket
import sys
raw = sys.argv[1].replace('\n', '\r\n').encode()
s = socket.create_connection(('127.0.0.1', 4242), timeout=2)
s.sendall(raw)
s.shutdown(socket.SHUT_WR)
data = b''
while True:
    chunk = s.recv(4096)
    if not chunk:
        break
    data += chunk
s.close()
sys.stdout.buffer.write(data)
PY
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
    -H 'Content-Type:' \
    --data 'amount=100&currency=usd' \
    'http://127.0.0.1:4242/v1/payment_intents'
assert_status 400
assert_body_contains 'invalid request'
printf '%s\n' 'ok - missing form content type'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=12xyz&currency=usd' \
    'http://127.0.0.1:4242/v1/payment_intents'
assert_status 400
assert_body_contains 'invalid request'
printf '%s\n' 'ok - malformed amount'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=100&amount=200&currency=usd' \
    'http://127.0.0.1:4242/v1/payment_intents'
assert_status 400
assert_body_contains 'invalid request'
printf '%s\n' 'ok - duplicate form field'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=100&currency=usd&extra=1' \
    'http://127.0.0.1:4242/v1/payment_intents'
assert_status 400
assert_body_contains 'invalid request'
printf '%s\n' 'ok - unknown form field'

request \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=100&currency=usd&note=Authorization%3A%20Bearer%20x86_test_key' \
    'http://127.0.0.1:4242/v1/payment_intents'
assert_status 401
assert_body_contains 'authentication required'
printf '%s\n' 'ok - credentials in body are not authentication'

request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/nope'
assert_status 404
assert_body_contains 'resource not found'
printf '%s\n' 'ok - unknown route'

printf '%s' 'amount=1&currency=usd&padding=' >"$TMP_DIR/oversized.body"
dd if=/dev/zero bs=9000 count=1 2>/dev/null | tr '\000' 'x' >>"$TMP_DIR/oversized.body"
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data-binary "@$TMP_DIR/oversized.body" \
    'http://127.0.0.1:4242/v1/payment_intents'
assert_status 413
assert_body_contains 'request body too large'
printf '%s\n' 'ok - oversized request rejection'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Idempotency-Key: multi-key-a' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=1500&currency=gbp' \
    'http://127.0.0.1:4242/v1/payment_intents'
assert_status 200
assert_body_contains '"id":"pi_x86_3"'
assert_body_contains '"amount":1500'
printf '%s\n' 'ok - multiple independent keys (key-a)'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Idempotency-Key: multi-key-b' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=2500&currency=jpy' \
    'http://127.0.0.1:4242/v1/payment_intents'
assert_status 200
assert_body_contains '"id":"pi_x86_4"'
assert_body_contains '"amount":2500'
printf '%s\n' 'ok - multiple independent keys (key-b)'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Idempotency-Key: multi-key-a' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=1500&currency=gbp' \
    'http://127.0.0.1:4242/v1/payment_intents'
assert_status 200
assert_body_contains '"id":"pi_x86_3"'
printf '%s\n' 'ok - cross-replay returns original result'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Idempotency-Key: multi-key-b' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=9999&currency=jpy' \
    'http://127.0.0.1:4242/v1/payment_intents'
assert_status 400
assert_body_contains 'idempotency key reused with different parameters'
printf '%s\n' 'ok - key reuse with different params conflict'

# Fill remaining idempotency table slots (4 used so far: demo-1,
# integration-key-1, multi-key-a, multi-key-b; capacity is 8).
i=1
while [ "$i" -le 4 ]; do
    request \
        -H 'Authorization: Bearer x86_test_key' \
        -H "Idempotency-Key: fill-key-${i}" \
        -H 'Content-Type: application/x-www-form-urlencoded' \
        --data "amount=$((i * 100))&currency=usd" \
        'http://127.0.0.1:4242/v1/payment_intents'
    assert_status 200
    i=$((i + 1))
done
printf '%s\n' 'ok - filled idempotency table'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Idempotency-Key: overflow-key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=100&currency=usd' \
    'http://127.0.0.1:4242/v1/payment_intents'
assert_status 507
assert_body_contains 'idempotency table full'
printf '%s\n' 'ok - idempotency table full'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=100&currency=usd' \
    'http://127.0.0.1:4242/v1/payment_intents'
assert_status 200
printf '%s\n' 'ok - request without key succeeds when table is full'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=4000&currency=usd' \
    'http://127.0.0.1:4242/v1/payment_intents'
assert_status 200
assert_header_contains 'Request-Id: req_x86_'
assert_body_contains '"request_id":"req_x86_'
printf '%s\n' 'ok - success carries request ID'

request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/nope'
assert_status 404
assert_header_contains 'Request-Id: req_x86_'
assert_body_contains '"type":"invalid_request_error"'
assert_body_contains '"code":"resource_not_found"'
assert_body_contains '"message":"resource not found"'
assert_body_contains '"request_id":"req_x86_'
printf '%s\n' 'ok - structured 404 error'

request \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=100&currency=usd' \
    'http://127.0.0.1:4242/v1/payment_intents'
assert_status 401
assert_header_contains 'Request-Id: req_x86_'
assert_body_contains '"type":"authentication_error"'
assert_body_contains '"code":"authentication_required"'
assert_body_contains '"message":"authentication required"'
printf '%s\n' 'ok - structured 401 error'

request \
    -H 'authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/payment_intents/pi_x86_1'
assert_status 200
assert_body_contains '"id":"pi_x86_1"'
printf '%s\n' 'ok - case-insensitive authorization'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'content-type: application/x-www-form-urlencoded' \
    --data 'amount=500&currency=eur' \
    'http://127.0.0.1:4242/v1/payment_intents'
assert_status 200
assert_body_contains '"amount":500'
printf '%s\n' 'ok - case-insensitive content type'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/payment_intents/pi_x86_1'
assert_status 400
assert_body_contains '"type":"invalid_request_error"'
assert_body_contains '"code":"invalid_request"'
printf '%s\n' 'ok - duplicate authorization rejected'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'authorization: Bearer wrong_key' \
    'http://127.0.0.1:4242/v1/payment_intents/pi_x86_1'
assert_status 400
assert_body_contains 'invalid request'
printf '%s\n' 'ok - conflicting authorization rejected'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=100&currency=usd' \
    'http://127.0.0.1:4242/v1/payment_intents'
assert_status 400
assert_body_contains 'invalid request'
printf '%s\n' 'ok - duplicate content type rejected'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Idempotency-Key: structured-dup-1' \
    -H 'Idempotency-Key: structured-dup-1' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=100&currency=usd' \
    'http://127.0.0.1:4242/v1/payment_intents'
assert_status 400
assert_body_contains 'invalid request'
printf '%s\n' 'ok - duplicate idempotency key rejected'

raw_request 'POST /v1/payment_intents HTTP/1.1
Host: 127.0.0.1
Authorization: Bearer x86_test_key
Content-Length: 23
content-length: 23
Content-Type: application/x-www-form-urlencoded
Connection: close

amount=100&currency=usd'
if ! grep -Fq '400' "$TMP_DIR/raw.resp"; then
    printf 'expected raw HTTP 400 for duplicate content length\n' >&2
    cat "$TMP_DIR/raw.resp" >&2
    exit 1
fi
if ! grep -Fq 'Request-Id: req_x86_' "$TMP_DIR/raw.resp"; then
    printf 'duplicate content length response missing request ID\n' >&2
    cat "$TMP_DIR/raw.resp" >&2
    exit 1
fi
printf '%s\n' 'ok - duplicate content length rejected'

# --- Users / Accounts / Ledger tests ---

# POST /v1/users - create first user
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'email=alice@example.com' \
    'http://127.0.0.1:4242/v1/users'
assert_status 201
assert_body_contains '"id":"user_x86_1"'
assert_body_contains '"object":"user"'
assert_body_contains '"email":"alice@example.com"'
printf '%s\n' 'ok - create user 1'

# POST /v1/users - create second user
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'email=bob@example.com' \
    'http://127.0.0.1:4242/v1/users'
assert_status 201
assert_body_contains '"id":"user_x86_2"'
assert_body_contains '"email":"bob@example.com"'
printf '%s\n' 'ok - create user 2'

# POST /v1/users - missing email field
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'name=charlie' \
    'http://127.0.0.1:4242/v1/users'
assert_status 400
assert_body_contains 'missing required field: email'
printf '%s\n' 'ok - user missing email'

# POST /v1/users - duplicate email
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'email=alice@example.com' \
    'http://127.0.0.1:4242/v1/users'
assert_status 409
assert_body_contains 'email already taken'
printf '%s\n' 'ok - duplicate email rejected'

# POST /v1/users - duplicate form field
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'email=duplicate-field@example.com&email=other@example.com' \
    'http://127.0.0.1:4242/v1/users'
assert_status 400
printf '%s\n' 'ok - duplicate user field rejected'

# POST /v1/accounts - create account for user 1
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'user_id=user_x86_1&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts'
assert_status 201
assert_body_contains '"id":"acct_x86_1"'
assert_body_contains '"object":"account"'
assert_body_contains '"user_id":"user_x86_1"'
assert_body_contains '"currency":"usd"'
assert_body_contains '"balance":0'
printf '%s\n' 'ok - create account 1'

# POST /v1/accounts - create account for user 2
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'user_id=user_x86_2&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts'
assert_status 201
assert_body_contains '"id":"acct_x86_2"'
assert_body_contains '"user_id":"user_x86_2"'
printf '%s\n' 'ok - create account 2'

# POST /v1/accounts - duplicate and unknown form fields
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'user_id=user_x86_1&user_id=user_x86_2&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts'
assert_status 400
printf '%s\n' 'ok - duplicate account field rejected'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'user_id=user_x86_1&currency=usd&extra=1' \
    'http://127.0.0.1:4242/v1/accounts'
assert_status 400
printf '%s\n' 'ok - unknown account field rejected'

# POST /v1/accounts - missing user_id
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'currency=usd' \
    'http://127.0.0.1:4242/v1/accounts'
assert_status 400
assert_body_contains 'missing required field: user_id'
printf '%s\n' 'ok - account missing user_id'

# POST /v1/accounts - missing currency
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'user_id=user_x86_1' \
    'http://127.0.0.1:4242/v1/accounts'
assert_status 400
assert_body_contains 'missing required field: currency'
printf '%s\n' 'ok - account missing currency'

# POST /v1/accounts - invalid user_id (non-existent)
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'user_id=user_x86_9&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts'
assert_status 404
assert_body_contains 'user not found'
printf '%s\n' 'ok - account with invalid user'

# POST /v1/accounts - invalid currency
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'user_id=user_x86_1&currency=eur' \
    'http://127.0.0.1:4242/v1/accounts'
assert_status 400
assert_body_contains 'currency must be usd'
printf '%s\n' 'ok - account with invalid currency'

# GET /v1/accounts/acct_x86_1 - retrieve account
request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1'
assert_status 200
assert_body_contains '"id":"acct_x86_1"'
assert_body_contains '"object":"account"'
assert_body_contains '"user_id":"user_x86_1"'
assert_body_contains '"currency":"usd"'
assert_body_contains '"balance":0'
printf '%s\n' 'ok - retrieve account'

# GET /v1/accounts/acct_x86_1/balance - retrieve balance
request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/balance'
assert_status 200
assert_body_contains '"balance":0'
printf '%s\n' 'ok - retrieve account balance'

# GET /v1/accounts/acct_x86_99 - non-existent account
request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_99'
assert_status 404
assert_body_contains 'resource not found'
printf '%s\n' 'ok - non-existent account returns 404'

# GET /v1/accounts/acct_x86_99/balance - non-existent account balance
request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_99/balance'
assert_status 404
assert_body_contains 'resource not found'
printf '%s\n' 'ok - non-existent account balance returns 404'

# GET /v1/transactions/txn_x86_1 - retrieve ledger entry (created with account 1)
request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/transactions/txn_x86_1'
assert_status 200
assert_body_contains '"id":"txn_x86_1"'
assert_body_contains '"object":"transaction"'
assert_body_contains '"account_id":"acct_x86_1"'
assert_body_contains '"amount":0'
assert_body_contains '"type":"account_opened"'
printf '%s\n' 'ok - retrieve ledger entry'

# Account creation must preserve the second opening transaction.
request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/transactions/txn_x86_2'
assert_status 200
assert_body_contains '"account_id":"acct_x86_2"'
assert_body_contains '"type":"account_opened"'
printf '%s\n' 'ok - opening transactions preserve slots'

# GET /v1/transactions/txn_x86_99 - non-existent transaction
request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/transactions/txn_x86_99'
assert_status 404
assert_body_contains 'transaction not found'
printf '%s\n' 'ok - non-existent transaction returns 404'

# Verify request IDs on new routes
request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1'
assert_header_contains 'Request-Id: req_x86_'
assert_body_contains '"request_id":"req_x86_'
printf '%s\n' 'ok - account response carries request ID'

request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/transactions/txn_x86_1'
assert_header_contains 'Request-Id: req_x86_'
assert_body_contains '"request_id":"req_x86_'
printf '%s\n' 'ok - transaction response carries request ID'

# --- Transfers / Withdrawals / Reversals / Events tests ---
# State so far: acct_x86_1 balance 0, acct_x86_2 balance 0,
# txn_x86_1/2 account_opened, no events.

# Minimal deposit to fund money-movement happy paths.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Idempotency-Key: deposit-account-1' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=5000&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/deposit'
assert_status 200
assert_body_contains '"id":"txn_x86_3"'
assert_body_contains '"type":"deposit"'
assert_body_contains '"amount":5000'
assert_header_contains 'Request-Id: req_x86_'
assert_body_contains '"request_id":"req_x86_'
printf '%s\n' 'ok - deposit funds account 1'

# Retrying a successful deposit must replay the original transaction without
# crediting the account or consuming another ledger slot.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Idempotency-Key: deposit-account-1' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=5000&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/deposit'
assert_status 200
assert_body_contains '"id":"txn_x86_3"'
assert_body_contains '"type":"deposit"'
printf '%s\n' 'ok - deposit idempotency replay'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Idempotency-Key: deposit-account-1' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=6000&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/deposit'
assert_status 400
assert_body_contains 'idempotency key reused with different parameters'
printf '%s\n' 'ok - deposit idempotency conflict'

request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/balance'
assert_status 200
assert_body_contains '"balance":5000'
printf '%s\n' 'ok - deposit credits balance'

request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1'
assert_status 200
assert_body_contains '"balance":5000'
printf '%s\n' 'ok - account reflects deposit'

# Deposit rejected: missing amount, no mutation.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'currency=usd' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/deposit'
assert_status 400
assert_body_contains 'missing required field: amount'
printf '%s\n' 'ok - deposit missing amount'

# Deposit rejected: invalid currency, no mutation.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=100&currency=eur' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/deposit'
assert_status 400
assert_body_contains 'currency must be usd'
printf '%s\n' 'ok - deposit invalid currency'

# Deposit rejected: missing currency, no mutation.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=100' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/deposit'
assert_status 400
assert_body_contains 'missing required field: currency'
printf '%s\n' 'ok - deposit missing currency'

# Deposit rejected: duplicate field, no mutation.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=100&amount=200&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/deposit'
assert_status 400
assert_body_contains 'invalid request'
printf '%s\n' 'ok - deposit duplicate amount'

# Deposit rejected: nonexistent account.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=100&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_99/deposit'
assert_status 404
assert_body_contains 'resource not found'
printf '%s\n' 'ok - deposit nonexistent account'

request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/balance'
assert_status 200
assert_body_contains '"balance":5000'
printf '%s\n' 'ok - rejected deposits leave balance unchanged'

# Send happy path: debit sender, credit recipient atomically.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Idempotency-Key: send-account-1' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'to_account_id=acct_x86_2&amount=1000&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/send'
assert_status 200
assert_body_contains '"id":"txn_x86_4"'
assert_body_contains '"sender_id":"acct_x86_1"'
assert_body_contains '"recipient_id":"acct_x86_2"'
assert_body_contains '"amount":1000'
assert_body_contains '"type":"transfer"'
assert_header_contains 'Request-Id: req_x86_'
assert_body_contains '"request_id":"req_x86_'
printf '%s\n' 'ok - send transfers funds'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Idempotency-Key: send-account-1' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'to_account_id=acct_x86_2&amount=1000&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/send'
assert_status 200
assert_body_contains '"id":"txn_x86_4"'
assert_body_contains '"type":"transfer"'
printf '%s\n' 'ok - send idempotency replay'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Idempotency-Key: send-account-1' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'to_account_id=acct_x86_1&amount=1000&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_2/send'
assert_status 400
assert_body_contains 'idempotency key reused with different parameters'
printf '%s\n' 'ok - send idempotency account conflict'

request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/balance'
assert_status 200
assert_body_contains '"balance":4000'
request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_2/balance'
assert_status 200
assert_body_contains '"balance":1000'
printf '%s\n' 'ok - send updates both balances'

# Send rejected: self-send, no mutation.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'to_account_id=acct_x86_1&amount=100&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/send'
assert_status 400
assert_body_contains 'cannot send to self'
printf '%s\n' 'ok - self-send rejected'

# Send rejected: missing to_account_id.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=100&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/send'
assert_status 400
assert_body_contains 'missing required field: to_account_id'
printf '%s\n' 'ok - send missing recipient'

# Send rejected: zero amount.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'to_account_id=acct_x86_2&amount=0&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/send'
assert_status 400
assert_body_contains 'invalid request'
printf '%s\n' 'ok - send zero amount rejected'

# Send rejected: duplicate field.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'to_account_id=acct_x86_2&amount=100&amount=200&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/send'
assert_status 400
assert_body_contains 'invalid request'
printf '%s\n' 'ok - send duplicate field rejected'

# Send rejected: unknown field.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'to_account_id=acct_x86_2&amount=100&currency=usd&extra=1' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/send'
assert_status 400
assert_body_contains 'invalid request'
printf '%s\n' 'ok - send unknown field rejected'

# Send rejected: nonexistent recipient.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'to_account_id=acct_x86_99&amount=100&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/send'
assert_status 404
assert_body_contains 'resource not found'
printf '%s\n' 'ok - send nonexistent recipient'

# Send rejected: insufficient funds, atomic (both balances unchanged, no new txn).
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'to_account_id=acct_x86_2&amount=99999999&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/send'
assert_status 402
assert_body_contains 'insufficient funds'
printf '%s\n' 'ok - send insufficient funds'

request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/balance'
assert_status 200
assert_body_contains '"balance":4000'
request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_2/balance'
assert_status 200
assert_body_contains '"balance":1000'
request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/transactions/txn_x86_5'
assert_status 404
assert_body_contains 'transaction not found'
printf '%s\n' 'ok - rejected sends are atomic'

# Withdraw happy path.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Idempotency-Key: withdraw-account-1' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=500&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/withdraw'
assert_status 200
assert_body_contains '"id":"txn_x86_5"'
assert_body_contains '"type":"withdrawal"'
assert_body_contains '"amount":500'
assert_header_contains 'Request-Id: req_x86_'
printf '%s\n' 'ok - withdraw debits account'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Idempotency-Key: withdraw-account-1' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=500&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/withdraw'
assert_status 200
assert_body_contains '"id":"txn_x86_5"'
assert_body_contains '"type":"withdrawal"'
printf '%s\n' 'ok - withdraw idempotency replay'

request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/balance'
assert_status 200
assert_body_contains '"balance":3500'
printf '%s\n' 'ok - withdraw updates balance'

# Withdraw rejected: insufficient funds, atomic.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=99999999&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/withdraw'
assert_status 402
assert_body_contains 'insufficient funds'
request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/balance'
assert_status 200
assert_body_contains '"balance":3500'
printf '%s\n' 'ok - withdraw insufficient funds atomic'

# Withdraw rejected: invalid amount.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=0&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/withdraw'
assert_status 400
assert_body_contains 'invalid request'
printf '%s\n' 'ok - withdraw invalid amount'

# Ledger retrieval for new money-movement types.
request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/transactions/txn_x86_4'
assert_status 200
assert_body_contains '"type":"transfer"'
assert_body_contains '"sender_id":"acct_x86_1"'
assert_body_contains '"recipient_id":"acct_x86_2"'
printf '%s\n' 'ok - retrieve transfer entry'

request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/transactions/txn_x86_5'
assert_status 200
assert_body_contains '"type":"withdrawal"'
assert_body_contains '"amount":500'
printf '%s\n' 'ok - retrieve withdrawal entry'

request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/transactions/txn_x86_3'
assert_status 200
assert_body_contains '"type":"deposit"'
printf '%s\n' 'ok - retrieve deposit entry'

# Reverse happy path (transfer): restores both balances.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -X POST \
    'http://127.0.0.1:4242/v1/transactions/txn_x86_4/reverse'
assert_status 200
assert_body_contains '"id":"txn_x86_6"'
assert_body_contains '"type":"reversal"'
assert_body_contains '"transaction_id":"txn_x86_4"'
assert_header_contains 'Request-Id: req_x86_'
printf '%s\n' 'ok - reverse transfer restores balances'

request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/balance'
assert_status 200
assert_body_contains '"balance":4500'
request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_2/balance'
assert_status 200
assert_body_contains '"balance":0'
printf '%s\n' 'ok - reversal updates both balances'

# Reverse rejected: already reversed, no mutation.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -X POST \
    'http://127.0.0.1:4242/v1/transactions/txn_x86_4/reverse'
assert_status 400
assert_body_contains 'transaction already reversed'
request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/balance'
assert_status 200
assert_body_contains '"balance":4500'
request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_2/balance'
assert_status 200
assert_body_contains '"balance":0'
printf '%s\n' 'ok - double reversal rejected atomically'

# Reverse rejected: account_opened cannot be reversed.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -X POST \
    'http://127.0.0.1:4242/v1/transactions/txn_x86_1/reverse'
assert_status 400
assert_body_contains 'cannot reverse this transaction'
printf '%s\n' 'ok - account_opened reversal rejected'

# Reverse rejected: unknown transaction, no mutation.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -X POST \
    'http://127.0.0.1:4242/v1/transactions/txn_x86_99/reverse'
assert_status 404
assert_body_contains 'transaction not found'
request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/balance'
assert_status 200
assert_body_contains '"balance":4500'
printf '%s\n' 'ok - unknown reversal rejected atomically'

# Reverse happy path (withdrawal): credits account.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -X POST \
    'http://127.0.0.1:4242/v1/transactions/txn_x86_5/reverse'
assert_status 200
assert_body_contains '"id":"txn_x86_7"'
assert_body_contains '"transaction_id":"txn_x86_5"'
request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/balance'
assert_status 200
assert_body_contains '"balance":5000'
printf '%s\n' 'ok - reverse withdrawal restores balance'

# Events: single retrieval and list.
request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/events/evt_x86_1'
assert_status 200
assert_body_contains '"id":"evt_x86_1"'
assert_body_contains '"object":"event"'
assert_body_contains 'deposit.created'
assert_body_contains '"transaction_id":"txn_x86_3"'
assert_header_contains 'Request-Id: req_x86_'
printf '%s\n' 'ok - retrieve single event'

request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/events/evt_x86_99'
assert_status 404
assert_body_contains 'event not found'
printf '%s\n' 'ok - unknown event returns 404'

request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/events'
assert_status 200
assert_body_contains '"object":"list"'
assert_body_contains 'transfer.created'
assert_body_contains 'withdrawal.created'
assert_body_contains 'reversal.created'
assert_header_contains 'Request-Id: req_x86_'
assert_body_contains '"request_id":"req_x86_'
printf '%s\n' 'ok - list events'

# Ledger capacity: fill txn table via account creation (7 used, cap 16).
i=3
while [ "$i" -le 11 ]; do
    request \
        -H 'Authorization: Bearer x86_test_key' \
        -H 'Content-Type: application/x-www-form-urlencoded' \
        --data 'user_id=user_x86_1&currency=usd' \
        'http://127.0.0.1:4242/v1/accounts'
    assert_status 201
    i=$((i + 1))
done
printf '%s\n' 'ok - filled ledger table'

# Domain validation must run before ledger-capacity validation.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'to_account_id=acct_x86_2&amount=99999999&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/send'
assert_status 402
assert_body_contains 'insufficient funds'
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'amount=99999999&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/withdraw'
assert_status 402
assert_body_contains 'insufficient funds'
printf '%s\n' 'ok - domain errors precede ledger capacity'

# Account creation must fail before mutating when the ledger is full.
request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'user_id=user_x86_1&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts'
assert_status 507
assert_body_contains 'table full'
request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_12'
assert_status 404
printf '%s\n' 'ok - account creation capacity is atomic'

request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/transactions/txn_x86_17'
assert_status 404
assert_body_contains 'transaction not found'
printf '%s\n' 'ok - transaction retrieval stays within capacity'

request \
    -H 'Authorization: Bearer x86_test_key' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data 'to_account_id=acct_x86_2&amount=100&currency=usd' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/send'
assert_status 507
assert_body_contains 'table full'
request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_1/balance'
assert_status 200
assert_body_contains '"balance":5000'
request \
    -H 'Authorization: Bearer x86_test_key' \
    'http://127.0.0.1:4242/v1/accounts/acct_x86_2/balance'
assert_status 200
assert_body_contains '"balance":0'
printf '%s\n' 'ok - ledger capacity rejected atomically'
printf '%s\n' 'all integration tests passed'
