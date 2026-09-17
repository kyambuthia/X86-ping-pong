#!/bin/sh
set -eu

# Run one mixed-workload worker. The coordinator supplies a unique numeric
# agent ID and the shared baseline accounts through X86PAY_LOAD_* variables.

AGENT_ID=${1:?agent id is required}
BASE_URL=${X86PAY_LOAD_BASE_URL:-http://127.0.0.1:4242}
API_KEY=${X86PAY_LOAD_API_KEY:-x86_test_key}
LOAD_DIR=${X86PAY_LOAD_DIR:?X86PAY_LOAD_DIR is required}
SOURCE_ACCOUNT=${X86PAY_LOAD_SOURCE_ACCOUNT:?X86PAY_LOAD_SOURCE_ACCOUNT is required}
TARGET_ACCOUNT=${X86PAY_LOAD_TARGET_ACCOUNT:?X86PAY_LOAD_TARGET_ACCOUNT is required}

LOG_FILE=$LOAD_DIR/agent-${AGENT_ID}.tsv
BODY_DIR=$LOAD_DIR/bodies
mkdir -p "$BODY_DIR"
printf 'agent\tsequence\toperation\tstatus\ttotal_seconds\tttfb_seconds\tbytes\tbody_excerpt\n' >"$LOG_FILE"

sequence=0

record_request() {
    operation=$1
    shift
    sequence=$((sequence + 1))
    body_file=$BODY_DIR/agent-${AGENT_ID}-${sequence}.body
    error_file=$BODY_DIR/agent-${AGENT_ID}-${sequence}.err
    : >"$body_file"
    : >"$error_file"
    metrics=$(curl -sS --connect-timeout 2 --max-time 10 \
        -o "$body_file" \
        -w '%{http_code}\t%{time_total}\t%{time_starttransfer}\t%{size_download}' \
        "$@" 2>"$error_file" || true)

    if [ -z "$metrics" ]; then
        metrics=$(printf '000\t10.000000\t10.000000\t0')
    fi

    old_ifs=$IFS
    IFS=$(printf '\t')
    set -- $metrics
    IFS=$old_ifs
    status=${1:-000}
    total=${2:-0}
    ttfb=${3:-0}
    bytes=${4:-0}
    excerpt=$(tr '\r\n\t' '   ' <"$body_file" 2>/dev/null | cut -c1-240)
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$AGENT_ID" "$sequence" "$operation" "$status" "$total" "$ttfb" "$bytes" "$excerpt" >>"$LOG_FILE"
}

extract_id() {
    sed -n 's/.*"id":"\([^"]*\)".*/\1/p' "$1"
}

auth_header="Authorization: Bearer $API_KEY"
form_header='Content-Type: application/x-www-form-urlencoded'

record_request create_user \
    -X POST "$BASE_URL/v1/users" \
    -H "$auth_header" -H "$form_header" \
    --data "email=load-agent-${AGENT_ID}@example.com"
worker_user=$(extract_id "$BODY_DIR/agent-${AGENT_ID}-1.body")

worker_account=
if [ -n "$worker_user" ]; then
    record_request create_account \
        -X POST "$BASE_URL/v1/accounts" \
        -H "$auth_header" -H "$form_header" \
        --data "user_id=$worker_user&currency=usd"
    worker_account=$(extract_id "$BODY_DIR/agent-${AGENT_ID}-2.body")
fi

account=${worker_account:-$SOURCE_ACCOUNT}

record_request payment_intent \
    -X POST "$BASE_URL/v1/payment_intents" \
    -H "$auth_header" -H "$form_header" \
    -H "Idempotency-Key: load-agent-${AGENT_ID}-payment" \
    --data "amount=$((100 + AGENT_ID))&currency=usd"
payment_intent=$(extract_id "$BODY_DIR/agent-${AGENT_ID}-$sequence.body")

record_request deposit \
    -X POST "$BASE_URL/v1/accounts/$account/deposit" \
    -H "$auth_header" -H "$form_header" \
    -H "Idempotency-Key: load-agent-${AGENT_ID}-deposit" \
    --data "amount=$((10 + AGENT_ID))&currency=usd"
deposit_transaction=$(extract_id "$BODY_DIR/agent-${AGENT_ID}-$sequence.body")

record_request account_retrieve \
    "$BASE_URL/v1/accounts/$account" \
    -H "$auth_header"

record_request balance \
    "$BASE_URL/v1/accounts/$account/balance" \
    -H "$auth_header"

record_request send \
    -X POST "$BASE_URL/v1/accounts/$account/send" \
    -H "$auth_header" -H "$form_header" \
    -H "Idempotency-Key: load-agent-${AGENT_ID}-send" \
    --data "to_account_id=$TARGET_ACCOUNT&amount=1&currency=usd"
send_transaction=$(extract_id "$BODY_DIR/agent-${AGENT_ID}-$sequence.body")

record_request withdraw \
    -X POST "$BASE_URL/v1/accounts/$account/withdraw" \
    -H "$auth_header" -H "$form_header" \
    -H "Idempotency-Key: load-agent-${AGENT_ID}-withdraw" \
    --data 'amount=1&currency=usd'
withdraw_transaction=$(extract_id "$BODY_DIR/agent-${AGENT_ID}-$sequence.body")

lookup_transaction=${deposit_transaction:-${send_transaction:-${withdraw_transaction:-}}}
if [ -z "$lookup_transaction" ]; then
    lookup_transaction=${X86PAY_LOAD_BOOTSTRAP_TRANSACTION:-}
fi

if [ -n "$lookup_transaction" ]; then
    record_request transaction_retrieve \
        "$BASE_URL/v1/transactions/$lookup_transaction" \
        -H "$auth_header"
    record_request transaction_reverse \
        -X POST "$BASE_URL/v1/transactions/$lookup_transaction/reverse" \
        -H "$auth_header"
fi

record_request events_list \
    "$BASE_URL/v1/events" \
    -H "$auth_header"

if [ -n "$payment_intent" ]; then
    record_request payment_intent_retrieve \
        "$BASE_URL/v1/payment_intents/$payment_intent" \
        -H "$auth_header"
fi

record_request final_balance \
    "$BASE_URL/v1/accounts/$account/balance" \
    -H "$auth_header"
