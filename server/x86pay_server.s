#define rel rip +
.intel_syntax noprefix

.section .data

.align 8
server_addr:
    .word 2                 # AF_INET
    .word 0x9210            # port 4242 in network byte order
    .long 0x0100007f        # 127.0.0.1
    .quad 0

reuse_value:
    .long 1

uid_hex_chars:
    .ascii "0123456789abcdef"

# timeval for SO_RCVTIMEO/SO_SNDTIMEO: 5s conservative request/response timeout.
socket_timeout:
    .quad 5
    .quad 0

# kernel_sigaction with handler = SIG_IGN; used to ignore SIGPIPE.
sigpipe_action:
    .quad 1                 # SIG_IGN
    .quad 0                 # flags
    .quad 0                 # restorer
    .quad 0                 # mask

auth_header:
    .ascii "\r\nAuthorization: Bearer x86_test_key\r\n"
auth_header_end:
.equ auth_header_len, auth_header_end - auth_header

idem_header:
    .ascii "\r\nIdempotency-Key: "
idem_header_end:
.equ idem_header_len, idem_header_end - idem_header

post_route:
    .ascii "POST /v1/payment_intents "
post_route_end:
.equ post_route_len, post_route_end - post_route

get_route:
    .ascii "GET /v1/payment_intents/pi_"
get_route_end:
.equ get_route_len, get_route_end - get_route

content_length_header:
    .ascii "\r\nContent-Length: "
content_length_header_end:
.equ content_length_header_len, content_length_header_end - content_length_header

content_type_header:
    .ascii "\r\nContent-Type: application/x-www-form-urlencoded\r\n"
content_type_header_end:
.equ content_type_header_len, content_type_header_end - content_type_header

header_end_marker:
    .ascii "\r\n\r\n"
header_end_marker_end:
.equ header_end_marker_len, header_end_marker_end - header_end_marker

amount_key:
    .ascii "amount="
amount_key_end:
.equ amount_key_len, amount_key_end - amount_key

currency_key:
    .ascii "currency="
currency_key_end:
.equ currency_key_len, currency_key_end - currency_key

http_prefix:
    .ascii "HTTP/1.1 "
http_prefix_end:
.equ http_prefix_len, http_prefix_end - http_prefix

http_headers:
    .ascii "\r\nContent-Type: application/json\r\nContent-Length: "
http_headers_end:
.equ http_headers_len, http_headers_end - http_headers

http_suffix:
    .ascii "\r\nConnection: close\r\n\r\n"
http_suffix_end:
.equ http_suffix_len, http_suffix_end - http_suffix

json_id_prefix:
    .ascii "{\"id\":\"pi_"
json_id_prefix_end:
.equ json_id_prefix_len, json_id_prefix_end - json_id_prefix

json_object_amount:
    .ascii "\",\"object\":\"payment_intent\",\"amount\":"
json_object_amount_end:
.equ json_object_amount_len, json_object_amount_end - json_object_amount

json_currency_prefix:
    .ascii ",\"currency\":\""
json_currency_prefix_end:
.equ json_currency_prefix_len, json_currency_prefix_end - json_currency_prefix

json_status_suffix:
    .ascii "\",\"status\":\"requires_payment_method\"}"
json_status_suffix_end:
.equ json_status_suffix_len, json_status_suffix_end - json_status_suffix

.equ IDEM_TABLE_CAP, 8
.equ IDEM_ENTRY_SZ, 296
.equ IDEM_KEY_LEN_OFF, 256
.equ IDEM_AMOUNT_OFF, 264
.equ IDEM_CURRENCY_OFF, 272
.equ IDEM_CONTEXT_OFF, 280
.equ IDEM_SEQ_OFF, 288
.equ UID_HEX_LEN, 16

json_status_mid:
    .ascii "\",\"status\":\"requires_payment_method\",\"request_id\":\"req_x86_"
json_status_mid_end:
.equ json_status_mid_len, json_status_mid_end - json_status_mid

json_status_end:
    .ascii "\"}"
json_status_end_end:
.equ json_status_end_len, json_status_end_end - json_status_end

status_200:
    .ascii "200 OK"
status_200_end:
.equ status_200_len, status_200_end - status_200

status_400:
    .ascii "400 Bad Request"
status_400_end:
.equ status_400_len, status_400_end - status_400

status_401:
    .ascii "401 Unauthorized"
status_401_end:
.equ status_401_len, status_401_end - status_401

status_404:
    .ascii "404 Not Found"
status_404_end:
.equ status_404_len, status_404_end - status_404

status_413:
    .ascii "413 Payload Too Large"
status_413_end:
.equ status_413_len, status_413_end - status_413

body_400:
    .ascii "{\"error\":{\"message\":\"invalid request\"}}"
body_400_end:
.equ body_400_len, body_400_end - body_400

body_401:
    .ascii "{\"error\":{\"message\":\"authentication required\"}}"
body_401_end:
.equ body_401_len, body_401_end - body_401

body_404:
    .ascii "{\"error\":{\"message\":\"resource not found\"}}"
body_404_end:
.equ body_404_len, body_404_end - body_404

body_413:
    .ascii "{\"error\":{\"message\":\"request body too large\"}}"
body_413_end:
.equ body_413_len, body_413_end - body_413

body_idem_conflict:
    .ascii "{\"error\":{\"message\":\"idempotency key reused with different parameters\"}}"
body_idem_conflict_end:
.equ body_idem_conflict_len, body_idem_conflict_end - body_idem_conflict

status_507:
    .ascii "507 Insufficient Storage"
status_507_end:
.equ status_507_len, status_507_end - status_507

body_507:
    .ascii "{\"error\":{\"message\":\"idempotency table full\"}}"
body_507_end:
.equ body_507_len, body_507_end - body_507

auth_name:
    .ascii "\r\nAuthorization:"
auth_name_end:
.equ auth_name_len, auth_name_end - auth_name

auth_expected:
    .ascii "Bearer x86_test_key"
auth_expected_end:
.equ auth_expected_len, auth_expected_end - auth_expected

cl_name:
    .ascii "\r\nContent-Length:"
cl_name_end:
.equ cl_name_len, cl_name_end - cl_name

ct_name:
    .ascii "\r\nContent-Type:"
ct_name_end:
.equ ct_name_len, ct_name_end - ct_name

ct_expected:
    .ascii "application/x-www-form-urlencoded"
ct_expected_end:
.equ ct_expected_len, ct_expected_end - ct_expected

idem_name:
    .ascii "\r\nIdempotency-Key:"
idem_name_end:
.equ idem_name_len, idem_name_end - idem_name

req_id_hdr_prefix:
    .ascii "\r\nRequest-Id: req_x86_"
req_id_hdr_prefix_end:
.equ req_id_hdr_prefix_len, req_id_hdr_prefix_end - req_id_hdr_prefix

err_prefix:
    .ascii "{\"error\":{\"type\":\""
err_prefix_end:
.equ err_prefix_len, err_prefix_end - err_prefix

err_code_sep:
    .ascii "\",\"code\":\""
err_code_sep_end:
.equ err_code_sep_len, err_code_sep_end - err_code_sep

err_msg_sep:
    .ascii "\",\"message\":\""
err_msg_sep_end:
.equ err_msg_sep_len, err_msg_sep_end - err_msg_sep

err_req_sep:
    .ascii "\",\"request_id\":\"req_x86_"
err_req_sep_end:
.equ err_req_sep_len, err_req_sep_end - err_req_sep

err_suffix:
    .ascii "\"}}"
err_suffix_end:
.equ err_suffix_len, err_suffix_end - err_suffix

type_invalid:
    .ascii "invalid_request_error"
type_invalid_end:
.equ type_invalid_len, type_invalid_end - type_invalid

code_invalid:
    .ascii "invalid_request"
code_invalid_end:
.equ code_invalid_len, code_invalid_end - code_invalid

msg_invalid:
    .ascii "invalid request"
msg_invalid_end:
.equ msg_invalid_len, msg_invalid_end - msg_invalid

type_auth:
    .ascii "authentication_error"
type_auth_end:
.equ type_auth_len, type_auth_end - type_auth

code_auth:
    .ascii "authentication_required"
code_auth_end:
.equ code_auth_len, code_auth_end - code_auth

msg_auth:
    .ascii "authentication required"
msg_auth_end:
.equ msg_auth_len, msg_auth_end - msg_auth

type_notfound:
    .ascii "invalid_request_error"
type_notfound_end:
.equ type_notfound_len, type_notfound_end - type_notfound

code_notfound:
    .ascii "resource_not_found"
code_notfound_end:
.equ code_notfound_len, code_notfound_end - code_notfound

msg_notfound:
    .ascii "resource not found"
msg_notfound_end:
.equ msg_notfound_len, msg_notfound_end - msg_notfound

type_toolarge:
    .ascii "invalid_request_error"
type_toolarge_end:
.equ type_toolarge_len, type_toolarge_end - type_toolarge

code_toolarge:
    .ascii "request_too_large"
code_toolarge_end:
.equ code_toolarge_len, code_toolarge_end - code_toolarge

msg_toolarge:
    .ascii "request body too large"
msg_toolarge_end:
.equ msg_toolarge_len, msg_toolarge_end - msg_toolarge

type_idem:
    .ascii "idempotency_error"
type_idem_end:
.equ type_idem_len, type_idem_end - type_idem

code_idem:
    .ascii "idempotency_key_in_use"
code_idem_end:
.equ code_idem_len, code_idem_end - code_idem

msg_idem:
    .ascii "idempotency key reused with different parameters"
msg_idem_end:
.equ msg_idem_len, msg_idem_end - msg_idem

type_storage:
    .ascii "api_error"
type_storage_end:
.equ type_storage_len, type_storage_end - type_storage

code_storage:
    .ascii "idempotency_table_full"
code_storage_end:
.equ code_storage_len, code_storage_end - code_storage

msg_storage:
    .ascii "idempotency table full"
msg_storage_end:
.equ msg_storage_len, msg_storage_end - msg_storage

# --- Users / Accounts / Ledger routes ---

post_users_route:
    .ascii "POST /v1/users "
post_users_route_end:
.equ post_users_route_len, post_users_route_end - post_users_route

post_accounts_route:
    .ascii "POST /v1/accounts "
post_accounts_route_end:
.equ post_accounts_route_len, post_accounts_route_end - post_accounts_route

get_accounts_route:
    .ascii "GET /v1/accounts/acct_"
get_accounts_route_end:
.equ get_accounts_route_len, get_accounts_route_end - get_accounts_route

get_txns_route:
    .ascii "GET /v1/transactions/txn_"
get_txns_route_end:
.equ get_txns_route_len, get_txns_route_end - get_txns_route

balance_suffix:
    .ascii "/balance "
balance_suffix_end:
.equ balance_suffix_len, balance_suffix_end - balance_suffix

# --- Table capacities ---

.equ USER_TABLE_CAP, 16
.equ USER_EMAIL_LEN, 120

.equ ACCT_TABLE_CAP, 16
.equ ACCT_CURRENCY_LEN, 4

.equ TXN_TABLE_CAP, 16
.equ TXN_TYPE_OPENED, 1
.equ TXN_TYPE_DEPOSIT, 5

# --- Form field keys ---

email_key:
    .ascii "email="
email_key_end:
.equ email_key_len, email_key_end - email_key

user_id_key:
    .ascii "user_id="
user_id_key_end:
.equ user_id_key_len, user_id_key_end - user_id_key

# --- JSON user prefixes ---

json_user_id_prefix:
    .ascii "{\"id\":\"usr_"
json_user_id_prefix_end:
.equ json_user_id_prefix_len, json_user_id_prefix_end - json_user_id_prefix

json_user_object_email:
    .ascii "\",\"object\":\"user\",\"email\":\""
json_user_object_email_end:
.equ json_user_object_email_len, json_user_object_email_end - json_user_object_email

json_user_email_reqid_mid:
    .ascii "\",\"request_id\":\"req_x86_"
json_user_email_reqid_mid_end:
.equ json_user_email_reqid_mid_len, json_user_email_reqid_mid_end - json_user_email_reqid_mid

# --- JSON account prefixes ---

json_acct_id_prefix:
    .ascii "{\"id\":\"acct_"
json_acct_id_prefix_end:
.equ json_acct_id_prefix_len, json_acct_id_prefix_end - json_acct_id_prefix

json_acct_object_userid:
    .ascii "\",\"object\":\"account\",\"user_id\":\"usr_"
json_acct_object_userid_end:
.equ json_acct_object_userid_len, json_acct_object_userid_end - json_acct_object_userid

json_acct_currency_mid:
    .ascii "\",\"currency\":\""
json_acct_currency_mid_end:
.equ json_acct_currency_mid_len, json_acct_currency_mid_end - json_acct_currency_mid

json_acct_balance_mid:
    .ascii "\",\"balance\":"
json_acct_balance_mid_end:
.equ json_acct_balance_mid_len, json_acct_balance_mid_end - json_acct_balance_mid

json_acct_reqid_mid:
    .ascii ",\"request_id\":\"req_x86_"
json_acct_reqid_mid_end:
.equ json_acct_reqid_mid_len, json_acct_reqid_mid_end - json_acct_reqid_mid

# --- JSON transaction prefixes ---

json_txn_id_prefix:
    .ascii "{\"id\":\"txn_"
json_txn_id_prefix_end:
.equ json_txn_id_prefix_len, json_txn_id_prefix_end - json_txn_id_prefix

json_txn_object_acctid:
    .ascii "\",\"object\":\"transaction\",\"account_id\":\"acct_"
json_txn_object_acctid_end:
.equ json_txn_object_acctid_len, json_txn_object_acctid_end - json_txn_object_acctid

json_txn_amount_mid:
    .ascii "\",\"amount\":"
json_txn_amount_mid_end:
.equ json_txn_amount_mid_len, json_txn_amount_mid_end - json_txn_amount_mid

json_txn_type_mid:
    .ascii ",\"type\":\""
json_txn_type_mid_end:
.equ json_txn_type_mid_len, json_txn_type_mid_end - json_txn_type_mid

json_txn_type_opened:
    .ascii "account_opened"
json_txn_type_opened_end:
.equ json_txn_type_opened_len, json_txn_type_opened_end - json_txn_type_opened

json_txn_reqid_mid:
    .ascii "\",\"request_id\":\"req_x86_"
json_txn_reqid_mid_end:
.equ json_txn_reqid_mid_len, json_txn_reqid_mid_end - json_txn_reqid_mid

# --- Balance-only response ---

json_balance_value:
    .ascii "{\"balance\":"
json_balance_value_end:
.equ json_balance_value_len, json_balance_value_end - json_balance_value

json_balance_reqid_mid:
    .ascii ",\"request_id\":\"req_x86_"
json_balance_reqid_mid_end:
.equ json_balance_reqid_mid_len, json_balance_reqid_mid_end - json_balance_reqid_mid

# --- Structured error for users/accounts ---

type_param_error:
    .ascii "invalid_request_error"
type_param_error_end:
.equ type_param_error_len, type_param_error_end - type_param_error

code_param_error:
    .ascii "invalid_request"
code_param_error_end:
.equ code_param_error_len, code_param_error_end - code_param_error

msg_missing_email:
    .ascii "missing required field: email"
msg_missing_email_end:
.equ msg_missing_email_len, msg_missing_email_end - msg_missing_email

msg_missing_user_id:
    .ascii "missing required field: user_id"
msg_missing_user_id_end:
.equ msg_missing_user_id_len, msg_missing_user_id_end - msg_missing_user_id

msg_missing_currency:
    .ascii "missing required field: currency"
msg_missing_currency_end:
.equ msg_missing_currency_len, msg_missing_currency_end - msg_missing_currency

msg_invalid_currency:
    .ascii "currency must be usd"
msg_invalid_currency_end:
.equ msg_invalid_currency_len, msg_invalid_currency_end - msg_invalid_currency

msg_user_not_found:
    .ascii "user not found"
msg_user_not_found_end:
.equ msg_user_not_found_len, msg_user_not_found_end - msg_user_not_found

msg_email_taken:
    .ascii "email already taken"
msg_email_taken_end:
.equ msg_email_taken_len, msg_email_taken_end - msg_email_taken

msg_email_too_long:
    .ascii "email too long"
msg_email_too_long_end:
.equ msg_email_too_long_len, msg_email_too_long_end - msg_email_too_long

msg_table_full:
    .ascii "table full"
msg_table_full_end:
.equ msg_table_full_len, msg_table_full_end - msg_table_full

msg_txn_not_found:
    .ascii "transaction not found"
msg_txn_not_found_end:
.equ msg_txn_not_found_len, msg_txn_not_found_end - msg_txn_not_found

# --- User ID prefix for validation ---
user_uid_prefix:
    .ascii "usr_"
user_uid_prefix_end:
.equ user_uid_prefix_len, user_uid_prefix_end - user_uid_prefix

# --- Status 201/409 ---
status_201:
    .ascii "201 Created"
status_201_end:
.equ status_201_len, status_201_end - status_201

status_409:
    .ascii "409 Conflict"
status_409_end:
.equ status_409_len, status_409_end - status_409

status_402:
    .ascii "402 Payment Required"
status_402_end:
.equ status_402_len, status_402_end - status_402

# --- Transfers / Withdrawals / Reversals / Events routes ---

post_acct_prefix:
    .ascii "POST /v1/accounts/acct_"
post_acct_prefix_end:
.equ post_acct_prefix_len, post_acct_prefix_end - post_acct_prefix

send_suffix:
    .ascii "/send "
send_suffix_end:
.equ send_suffix_len, send_suffix_end - send_suffix

withdraw_suffix:
    .ascii "/withdraw "
withdraw_suffix_end:
.equ withdraw_suffix_len, withdraw_suffix_end - withdraw_suffix

deposit_suffix:
    .ascii "/deposit "
deposit_suffix_end:
.equ deposit_suffix_len, deposit_suffix_end - deposit_suffix

post_txn_prefix:
    .ascii "POST /v1/transactions/txn_"
post_txn_prefix_end:
.equ post_txn_prefix_len, post_txn_prefix_end - post_txn_prefix

reverse_suffix:
    .ascii "/reverse "
reverse_suffix_end:
.equ reverse_suffix_len, reverse_suffix_end - reverse_suffix

get_events_list_route:
    .ascii "GET /v1/events "
get_events_list_route_end:
.equ get_events_list_route_len, get_events_list_route_end - get_events_list_route

get_events_prefix:
    .ascii "GET /v1/events/evt_"
get_events_prefix_end:
.equ get_events_prefix_len, get_events_prefix_end - get_events_prefix

# --- Form keys for money movement ---

to_account_id_key:
    .ascii "to_account_id="
to_account_id_key_end:
.equ to_account_id_key_len, to_account_id_key_end - to_account_id_key

acct_uid_prefix:
    .ascii "acct_"
acct_uid_prefix_end:
.equ acct_uid_prefix_len, acct_uid_prefix_end - acct_uid_prefix

# --- Txn type names ---

json_txn_type_transfer:
    .ascii "transfer"
json_txn_type_transfer_end:
.equ json_txn_type_transfer_len, json_txn_type_transfer_end - json_txn_type_transfer

json_txn_type_withdrawal:
    .ascii "withdrawal"
json_txn_type_withdrawal_end:
.equ json_txn_type_withdrawal_len, json_txn_type_withdrawal_end - json_txn_type_withdrawal

json_txn_type_deposit:
    .ascii "deposit"
json_txn_type_deposit_end:
.equ json_txn_type_deposit_len, json_txn_type_deposit_end - json_txn_type_deposit

json_txn_type_reversal:
    .ascii "reversal"
json_txn_type_reversal_end:
.equ json_txn_type_reversal_len, json_txn_type_reversal_end - json_txn_type_reversal

# --- Transfer JSON fragments ---

json_transfer_sender_mid:
    .ascii "\",\"object\":\"transaction\",\"sender_id\":\"acct_"
json_transfer_sender_mid_end:
.equ json_transfer_sender_mid_len, json_transfer_sender_mid_end - json_transfer_sender_mid

json_transfer_recipient_mid:
    .ascii "\",\"recipient_id\":\"acct_"
json_transfer_recipient_mid_end:
.equ json_transfer_recipient_mid_len, json_transfer_recipient_mid_end - json_transfer_recipient_mid

# --- Reversal JSON fragments ---

json_rev_txnid_mid:
    .ascii "\",\"object\":\"transaction\",\"transaction_id\":\"txn_"
json_rev_txnid_mid_end:
.equ json_rev_txnid_mid_len, json_rev_txnid_mid_end - json_rev_txnid_mid

# --- Event JSON fragments ---

json_evt_id_prefix:
    .ascii "{\"id\":\"evt_"
json_evt_id_prefix_end:
.equ json_evt_id_prefix_len, json_evt_id_prefix_end - json_evt_id_prefix

json_evt_object_type:
    .ascii "\",\"object\":\"event\",\"type\":\""
json_evt_object_type_end:
.equ json_evt_object_type_len, json_evt_object_type_end - json_evt_object_type

json_evt_txn_mid:
    .ascii "\",\"transaction_id\":\"txn_"
json_evt_txn_mid_end:
.equ json_evt_txn_mid_len, json_evt_txn_mid_end - json_evt_txn_mid

json_evt_amount_mid:
    .ascii "\",\"amount\":"
json_evt_amount_mid_end:
.equ json_evt_amount_mid_len, json_evt_amount_mid_end - json_evt_amount_mid

json_evt_currency_mid:
    .ascii ",\"currency\":\"usd\""
json_evt_currency_mid_end:
.equ json_evt_currency_mid_len, json_evt_currency_mid_end - json_evt_currency_mid

json_evt_reqid_mid:
    .ascii ",\"request_id\":\"req_x86_"
json_evt_reqid_mid_end:
.equ json_evt_reqid_mid_len, json_evt_reqid_mid_end - json_evt_reqid_mid

evt_kind_transfer:
    .ascii "transfer.created"
evt_kind_transfer_end:
.equ evt_kind_transfer_len, evt_kind_transfer_end - evt_kind_transfer

evt_kind_withdrawal:
    .ascii "withdrawal.created"
evt_kind_withdrawal_end:
.equ evt_kind_withdrawal_len, evt_kind_withdrawal_end - evt_kind_withdrawal

evt_kind_deposit:
    .ascii "deposit.created"
evt_kind_deposit_end:
.equ evt_kind_deposit_len, evt_kind_deposit_end - evt_kind_deposit

evt_kind_reversal:
    .ascii "reversal.created"
evt_kind_reversal_end:
.equ evt_kind_reversal_len, evt_kind_reversal_end - evt_kind_reversal

json_events_list_prefix:
    .ascii "{\"object\":\"list\",\"data\":["
json_events_list_prefix_end:
.equ json_events_list_prefix_len, json_events_list_prefix_end - json_events_list_prefix

json_events_list_mid:
    .ascii "],\"request_id\":\"req_x86_"
json_events_list_mid_end:
.equ json_events_list_mid_len, json_events_list_mid_end - json_events_list_mid

json_comma:
    .ascii ","
json_comma_end:
.equ json_comma_len, json_comma_end - json_comma

json_rbrace:
    .ascii "}"
json_rbrace_end:
.equ json_rbrace_len, json_rbrace_end - json_rbrace

# --- Money-movement error messages ---

msg_missing_to_account:
    .ascii "missing required field: to_account_id"
msg_missing_to_account_end:
.equ msg_missing_to_account_len, msg_missing_to_account_end - msg_missing_to_account

msg_missing_amount:
    .ascii "missing required field: amount"
msg_missing_amount_end:
.equ msg_missing_amount_len, msg_missing_amount_end - msg_missing_amount

msg_self_send:
    .ascii "cannot send to self"
msg_self_send_end:
.equ msg_self_send_len, msg_self_send_end - msg_self_send

msg_insufficient:
    .ascii "insufficient funds"
msg_insufficient_end:
.equ msg_insufficient_len, msg_insufficient_end - msg_insufficient

msg_already_reversed:
    .ascii "transaction already reversed"
msg_already_reversed_end:
.equ msg_already_reversed_len, msg_already_reversed_end - msg_already_reversed

msg_cannot_reverse:
    .ascii "cannot reverse this transaction"
msg_cannot_reverse_end:
.equ msg_cannot_reverse_len, msg_cannot_reverse_end - msg_cannot_reverse

msg_event_not_found:
    .ascii "event not found"
msg_event_not_found_end:
.equ msg_event_not_found_len, msg_event_not_found_end - msg_event_not_found

code_insufficient:
    .ascii "insufficient_funds"
code_insufficient_end:
.equ code_insufficient_len, code_insufficient_end - code_insufficient

.equ EVENT_TABLE_CAP, 16
# txn types: 1=account_opened 2=transfer 3=withdrawal 4=reversal 5=deposit
# event kinds: 1=transfer 2=withdrawal 3=deposit 4=reversal

.section .bss

.align 8
request_buf:
    .zero 8192
response_buf:
    .zero 8192
json_buf:
    .zero 4096
num_buf:
    .zero 32
currency_tmp:
    .zero 4
current_idem:
    .zero 256

request_len:
    .quad 0
uid_seed:
    .quad 0
header_len:
    .quad 0
body_ptr:
    .quad 0
body_end:
    .quad 0
current_amount:
    .quad 0
current_idem_context:
    .quad 0
current_idem_len:
    .quad 0

idem_table:
    .zero IDEM_TABLE_CAP * IDEM_ENTRY_SZ
money_deposit_idem_table:
    .zero IDEM_TABLE_CAP * IDEM_ENTRY_SZ
money_send_idem_table:
    .zero IDEM_TABLE_CAP * IDEM_ENTRY_SZ
money_withdraw_idem_table:
    .zero IDEM_TABLE_CAP * IDEM_ENTRY_SZ
idem_table_ptr:
    .quad 0

form_amount_seen:
    .quad 0
form_currency_seen:
    .quad 0
form_token_end:
    .quad 0
form_token_len:
    .quad 0

intent_count:
    .quad 0
intent_amounts:
    .zero 128               # 16 x uint64
intent_currencies:
    .zero 64                # 16 x 4-byte currency values

send_status_ptr:
    .quad 0
send_status_len:
    .quad 0
send_body_ptr:
    .quad 0
send_body_len:
    .quad 0
response_seq:
    .quad 0
request_counter:
    .quad 0
current_req_id:
    .quad 0
hdr_tmp_first:
    .quad 0

# --- Users table ---
user_count:
    .quad 0
user_emails:
    .zero USER_TABLE_CAP * USER_EMAIL_LEN

# --- Accounts table ---
acct_count:
    .quad 0
acct_user_ids:
    .zero ACCT_TABLE_CAP * 8
acct_currencies:
    .zero ACCT_TABLE_CAP * ACCT_CURRENCY_LEN
acct_balances:
    .zero ACCT_TABLE_CAP * 8

# --- Transactions table ---
txn_count:
    .quad 0
txn_account_ids:
    .zero TXN_TABLE_CAP * 8
txn_amounts:
    .zero TXN_TABLE_CAP * 8
txn_types:
    .zero TXN_TABLE_CAP * 8
txn_extra:
    .zero TXN_TABLE_CAP * 8
txn_flags:
    .zero TXN_TABLE_CAP * 8
txn_link:
    .zero TXN_TABLE_CAP * 8

# --- Events table (bounded in-memory trail) ---
event_count:
    .quad 0
event_kinds:
    .zero EVENT_TABLE_CAP * 8
event_txn_ids:
    .zero EVENT_TABLE_CAP * 8
event_amounts:
    .zero EVENT_TABLE_CAP * 8

# --- Temp form value buffers ---
form_value_buf:
    .zero 256
form_value_len:
    .quad 0

# --- Temp extracted IDs ---
account_id:
    .quad 0
user_number:
    .quad 0
move_src:
    .quad 0
move_dst:
    .quad 0
move_amount:
    .quad 0
move_txn:
    .quad 0
cu_email_seen:
    .quad 0
ca_user_id_seen:
    .quad 0
ca_currency_seen:
    .quad 0
fv_to_seen:
    .quad 0
fv_amount_seen:
    .quad 0
fv_currency_seen:
    .quad 0
fv_to_num:
    .quad 0
fv_amount_val:
    .quad 0

.section .text
.global _start

_start:
    # Seed opaque resource IDs once per process. The low five bits are reserved
    # for the bounded table slot; the remaining bits identify this boot.
    mov eax, 318            # getrandom(uid_seed, 8, 0)
    lea rdi, [rel uid_seed]
    mov esi, 8
    xor edx, edx
    syscall
    cmp rax, 8
    je uid_seed_mask
    rdtsc
    shl rdx, 32
    or rax, rdx
    mov [rel uid_seed], rax
uid_seed_mask:
    mov rax, [rel uid_seed]
    and rax, -32
    jnz uid_seed_ready
    mov rax, 0x6a09e667f3bcc908
    mov [rel uid_seed], rax
uid_seed_ready:
    mov rax, [rel uid_seed]
    and rax, -32
    mov [rel uid_seed], rax

    # Ignore SIGPIPE so a peer that closes early cannot terminate the server.
    mov eax, 13             # rt_sigaction(SIGPIPE, &act, NULL, 8)
    mov edi, 13
    lea rsi, [rel sigpipe_action]
    xor edx, edx
    mov r10d, 8
    syscall

    # socket(AF_INET, SOCK_STREAM, 0)
    mov eax, 41
    mov edi, 2
    mov esi, 1
    xor edx, edx
    syscall
    test rax, rax
    js exit_failure
    mov r12, rax

    # setsockopt(server, SOL_SOCKET, SO_REUSEADDR, &reuse_value, 4)
    mov eax, 54
    mov rdi, r12
    mov esi, 1
    mov edx, 2
    lea r10, [rel reuse_value]
    mov r8d, 4
    syscall

    # bind(server, 127.0.0.1:4242, 16)
    mov eax, 49
    mov rdi, r12
    lea rsi, [rel server_addr]
    mov edx, 16
    syscall
    test rax, rax
    js exit_failure

    # listen(server, 16)
    mov eax, 50
    mov rdi, r12
    mov esi, 16
    syscall
    test rax, rax
    js exit_failure

accept_loop:
    # accept(server, NULL, NULL)
    mov eax, 43
    mov rdi, r12
    xor esi, esi
    xor edx, edx
    syscall
    cmp rax, -4             # EINTR
    je accept_loop
    test rax, rax
    js exit_failure
    mov r13, rax

    # SO_RCVTIMEO/SO_SNDTIMEO bound a stalled peer to the accept loop.
    mov eax, 54             # setsockopt(SOL_SOCKET, SO_RCVTIMEO, ...)
    mov rdi, r13
    mov esi, 1
    mov edx, 20             # SO_RCVTIMEO
    lea r10, [rel socket_timeout]
    mov r8d, 16
    syscall
    mov eax, 54
    mov rdi, r13
    mov esi, 1
    mov edx, 21             # SO_SNDTIMEO
    lea r10, [rel socket_timeout]
    mov r8d, 16
    syscall

    inc qword ptr [rel request_counter]
    mov rax, [rel request_counter]
    mov [rel current_req_id], rax

    call read_request
    test rax, rax
    jz close_client
    js request_read_error
    mov [rel request_len], rax
    call handle_request

close_client:
    mov eax, 3
    mov rdi, r13
    syscall
    jmp accept_loop

request_read_error:
    cmp rax, -2
    je request_too_large_response
    call respond_400
    jmp close_client

request_too_large_response:
    call respond_413
    jmp close_client

# read_request: read one request, including its declared body, into request_buf.
# Returns RAX=request length, 0 for a clean peer close, -1 for malformed input,
# and -2 when the request exceeds the fixed request buffer.
read_request:
    xor r14, r14

read_request_more:
    cmp r14, 8192
    jae read_request_too_large

    mov eax, 0
    mov rdi, r13
    lea rsi, [rel request_buf]
    add rsi, r14
    mov edx, 8192
    sub rdx, r14
    syscall
    cmp rax, -4           # EINTR
    je read_request_more
    cmp rax, -11          # EAGAIN from the receive timeout
    je read_request_timeout
    test rax, rax
    jle read_request_failed
    add r14, rax
    mov [rel request_len], r14

    # Wait until the complete HTTP header block is present.
    lea rbx, [rel request_buf]
    mov rsi, rbx
    mov rcx, r14
    lea rdi, [rel header_end_marker]
    mov edx, header_end_marker_len
    call find_sequence
    test rax, rax
    jz read_request_more_or_full

    # R15 is the number of bytes through the end of the header block.
    mov r15, rax
    sub r15, rbx
    add r15, header_end_marker_len
    mov [rel header_len], r15

    # Content-Length is matched case-insensitively by name. A request
    # without it is treated as a zero-length request (for GET).
    mov rsi, rbx
    mov rcx, r15
    lea rdi, [rel cl_name]
    mov edx, cl_name_len
    call find_sequence_ci
    test rax, rax
    jz read_request_without_body
    mov [rel hdr_tmp_first], rax
    # Reject duplicate Content-Length headers (case-insensitive).
    mov rsi, rax
    inc rsi
    mov r8, rbx
    add r8, r15
    cmp rsi, r8
    jae cl_no_duplicate
    mov rcx, r8
    sub rcx, rsi
    lea rdi, [rel cl_name]
    mov edx, cl_name_len
    call find_sequence_ci
    test rax, rax
    jnz read_request_failed
cl_no_duplicate:
    mov rax, [rel hdr_tmp_first]
    add rax, cl_name_len
    mov rsi, rax
    mov r8, rbx
    add r8, r15
    xor rdx, rdx
    xor r10d, r10d
    # Skip leading OWS (space / tab) after the colon.
cl_skip_leading:
    cmp rsi, r8
    jae read_request_failed
    movzx r9d, byte ptr [rsi]
    cmp r9b, 32
    je cl_skip_leading_inc
    cmp r9b, 9
    je cl_skip_leading_inc
    jmp cl_digits_start
cl_skip_leading_inc:
    inc rsi
    jmp cl_skip_leading
cl_digits_start:
    jmp parse_content_length

parse_content_length:
    cmp rsi, r8
    jae read_request_failed
    movzx r9d, byte ptr [rsi]
    cmp r9b, '0'
    jb content_length_done
    cmp r9b, '9'
    ja content_length_done

    # Reject values that cannot fit in the request buffer before multiplying.
    cmp rdx, 819
    ja read_request_too_large
    jne content_length_accumulate
    cmp r9b, '2'
    ja read_request_too_large

content_length_accumulate:
    imul rdx, rdx, 10
    sub r9d, '0'
    add rdx, r9
    inc rsi
    inc r10
    jmp parse_content_length

content_length_done:
    test r10, r10
    jz read_request_failed
    # Skip trailing OWS before the end of the header line.
cl_skip_trailing:
    cmp rsi, r8
    jae read_request_failed
    movzx r9d, byte ptr [rsi]
    cmp r9b, 32
    je cl_skip_trailing_inc
    cmp r9b, 9
    je cl_skip_trailing_inc
    jmp cl_check_eol
cl_skip_trailing_inc:
    inc rsi
    jmp cl_skip_trailing
cl_check_eol:
    cmp rsi, r8
    jae read_request_failed
    movzx r9d, byte ptr [rsi]
    cmp r9b, 13
    je content_length_valid
    cmp r9b, 10
    jne read_request_failed

content_length_valid:
    mov rax, r15
    add rax, rdx
    cmp rax, 8192
    ja read_request_too_large
    cmp r14, rax
    ja read_request_failed
    je read_request_complete
    jmp read_request_more

read_request_without_body:
    cmp r14, r15
    jne read_request_failed
    mov rax, r14
    ret

read_request_more_or_full:
    cmp r14, 8192
    jae read_request_too_large
    jmp read_request_more

read_request_complete:
    mov rax, r14
    ret

read_request_timeout:
    # Peer stalled past the receive timeout; drop the connection silently.
    xor eax, eax
    ret

read_request_failed:
    mov rax, -1
    ret

read_request_too_large:
    mov rax, -2
    ret

handle_request:
    lea rbx, [rel request_buf]

    # Authorization header name is case-insensitive; the value stays exact.
    # Missing or wrong credentials -> 401. Duplicates -> 400.
    mov rsi, rbx
    mov rcx, [rel header_len]
    lea rdi, [rel auth_name]
    mov edx, auth_name_len
    call find_sequence_ci
    test rax, rax
    jz respond_401
    mov [rel hdr_tmp_first], rax
    mov rsi, rax
    inc rsi
    mov r8, rbx
    add r8, [rel header_len]
    cmp rsi, r8
    jae auth_no_duplicate
    mov rcx, r8
    sub rcx, rsi
    lea rdi, [rel auth_name]
    mov edx, auth_name_len
    call find_sequence_ci
    test rax, rax
    jnz respond_400
auth_no_duplicate:
    mov rax, [rel hdr_tmp_first]
    add rax, auth_name_len
    mov rsi, rax
    mov r8, rbx
    add r8, [rel header_len]
auth_skip_leading:
    cmp rsi, r8
    jae respond_401
    movzx eax, byte ptr [rsi]
    cmp al, 32
    je auth_skip_leading_inc
    cmp al, 9
    je auth_skip_leading_inc
    jmp auth_value_start
auth_skip_leading_inc:
    inc rsi
    jmp auth_skip_leading
auth_value_start:
    mov rdx, rsi
auth_find_eol:
    cmp rdx, r8
    jae respond_401
    movzx eax, byte ptr [rdx]
    cmp al, 13
    je auth_eol_found
    cmp al, 10
    je auth_eol_found
    inc rdx
    jmp auth_find_eol
auth_eol_found:
    mov rcx, rdx
auth_trim_trailing:
    cmp rcx, rsi
    jbe auth_trim_done
    movzx eax, byte ptr [rcx - 1]
    cmp al, 32
    je auth_trim_dec
    cmp al, 9
    je auth_trim_dec
    jmp auth_trim_done
auth_trim_dec:
    dec rcx
    jmp auth_trim_trailing
auth_trim_done:
    mov rax, rcx
    sub rax, rsi
    cmp rax, auth_expected_len
    jne respond_401
    mov rcx, rax
    lea rdi, [rel auth_expected]
    call buffers_equal
    test eax, eax
    jz respond_401

    # POST /v1/payment_intents
    mov rsi, rbx
    mov rcx, [rel request_len]
    lea rdi, [rel post_route]
    mov edx, post_route_len
    call find_sequence
    cmp rax, rbx
    je create_intent

    # GET /v1/payment_intents/pi_<uid>
    mov rsi, rbx
    mov rcx, [rel request_len]
    lea rdi, [rel get_route]
    mov edx, get_route_len
    call find_sequence
    cmp rax, rbx
    je retrieve_intent

    # POST /v1/users
    mov rsi, rbx
    mov rcx, [rel request_len]
    lea rdi, [rel post_users_route]
    mov edx, post_users_route_len
    call find_sequence
    cmp rax, rbx
    je create_user

    # POST /v1/accounts
    mov rsi, rbx
    mov rcx, [rel request_len]
    lea rdi, [rel post_accounts_route]
    mov edx, post_accounts_route_len
    call find_sequence
    cmp rax, rbx
    je create_account

    # GET /v1/accounts/acct_<uid>[/balance]
    mov rsi, rbx
    mov rcx, [rel request_len]
    lea rdi, [rel get_accounts_route]
    mov edx, get_accounts_route_len
    call find_sequence
    cmp rax, rbx
    je route_get_account

    # GET /v1/transactions/txn_<uid>
    mov rsi, rbx
    mov rcx, [rel request_len]
    lea rdi, [rel get_txns_route]
    mov edx, get_txns_route_len
    call find_sequence
    cmp rax, rbx
    je retrieve_transaction

    # POST /v1/accounts/acct_<uid>/send|withdraw|deposit
    mov rsi, rbx
    mov rcx, [rel request_len]
    lea rdi, [rel post_acct_prefix]
    mov edx, post_acct_prefix_len
    call find_sequence
    cmp rax, rbx
    je route_post_account_money

    # POST /v1/transactions/txn_<uid>/reverse
    mov rsi, rbx
    mov rcx, [rel request_len]
    lea rdi, [rel post_txn_prefix]
    mov edx, post_txn_prefix_len
    call find_sequence
    cmp rax, rbx
    je route_post_txn_reverse

    # GET /v1/events/evt_<uid>
    mov rsi, rbx
    mov rcx, [rel request_len]
    lea rdi, [rel get_events_prefix]
    mov edx, get_events_prefix_len
    call find_sequence
    cmp rax, rbx
    je retrieve_event

    # GET /v1/events (list)
    mov rsi, rbx
    mov rcx, [rel request_len]
    lea rdi, [rel get_events_list_route]
    mov edx, get_events_list_route_len
    call find_sequence
    cmp rax, rbx
    je list_events

    jmp respond_404

create_intent:
    lea rax, [rel idem_table]
    mov [rel idem_table_ptr], rax
    mov qword ptr [rel current_idem_context], 0
    # POST bodies must use the form encoding understood by this slice.
    # Content-Type name is case-insensitive; value stays exact.
    mov rsi, rbx
    mov rcx, [rel header_len]
    lea rdi, [rel ct_name]
    mov edx, ct_name_len
    call find_sequence_ci
    test rax, rax
    jz respond_400
    mov [rel hdr_tmp_first], rax
    mov rsi, rax
    inc rsi
    mov r8, rbx
    add r8, [rel header_len]
    cmp rsi, r8
    jae ct_no_duplicate
    mov rcx, r8
    sub rcx, rsi
    lea rdi, [rel ct_name]
    mov edx, ct_name_len
    call find_sequence_ci
    test rax, rax
    jnz respond_400
ct_no_duplicate:
    mov rax, [rel hdr_tmp_first]
    add rax, ct_name_len
    mov rsi, rax
    mov r8, rbx
    add r8, [rel header_len]
ct_skip_leading:
    cmp rsi, r8
    jae respond_400
    movzx eax, byte ptr [rsi]
    cmp al, 32
    je ct_skip_leading_inc
    cmp al, 9
    je ct_skip_leading_inc
    jmp ct_value_start
ct_skip_leading_inc:
    inc rsi
    jmp ct_skip_leading
ct_value_start:
    mov rdx, rsi
ct_find_eol:
    cmp rdx, r8
    jae respond_400
    movzx eax, byte ptr [rdx]
    cmp al, 13
    je ct_eol_found
    cmp al, 10
    je ct_eol_found
    inc rdx
    jmp ct_find_eol
ct_eol_found:
    mov rcx, rdx
ct_trim_trailing:
    cmp rcx, rsi
    jbe ct_trim_done
    movzx eax, byte ptr [rcx - 1]
    cmp al, 32
    je ct_trim_dec
    cmp al, 9
    je ct_trim_dec
    jmp ct_trim_done
ct_trim_dec:
    dec rcx
    jmp ct_trim_trailing
ct_trim_done:
    mov rax, rcx
    sub rax, rsi
    cmp rax, ct_expected_len
    jne respond_400
    mov rcx, rax
    lea rdi, [rel ct_expected]
    call buffers_equal
    test eax, eax
    jz respond_400

    # Locate the form body.
    mov rax, rbx
    add rax, [rel header_len]
    mov [rel body_ptr], rax
    mov rdx, rbx
    add rdx, [rel request_len]
    mov [rel body_end], rdx

    # Parse exactly amount=<digits>&currency=<three lowercase letters> fields.
    call parse_form
    test eax, eax
    jz respond_400

    lea rbx, [rel request_buf]
    call parse_idempotency
    test eax, eax
    jz respond_400
    call check_idempotency
    test rax, rax
    js respond_idem_conflict
    jz create_new_intent
    call send_intent_response
    ret

create_new_intent:
    mov rbx, [rel intent_count]
    cmp rbx, 16
    jae respond_400

    # If there is an idempotency key, verify the table has space before
    # creating the intent so the sequence stays gap-free on overflow.
    mov rcx, [rel current_idem_len]
    test rcx, rcx
    jz create_intent_store_arrays

    mov r11, [rel idem_table_ptr]
    xor r10d, r10d
find_slot_loop:
    cmp r10, IDEM_TABLE_CAP
    jae respond_table_full
    cmp qword ptr [r11 + IDEM_SEQ_OFF], 0
    je create_intent_store_arrays
    inc r10
    add r11, IDEM_ENTRY_SZ
    jmp find_slot_loop

create_intent_store_arrays:
    lea rdi, [rel intent_amounts]
    mov rax, [rel current_amount]
    mov [rdi + rbx * 8], rax

    lea rdi, [rel intent_currencies]
    mov eax, [rel currency_tmp]
    mov [rdi + rbx * 4], eax

    inc qword ptr [rel intent_count]
    lea rax, [rbx + 1]
    mov [rel response_seq], rax

    call store_idempotency

    mov rax, [rel response_seq]
    call send_intent_response
    ret

retrieve_intent:
    lea rsi, [rbx + get_route_len]
    mov r8, rbx
    add r8, [rel request_len]
    call decode_uid_token
    test rax, rax
    jz respond_404
    cmp rsi, r8
    jae id_path_ended
    cmp byte ptr [rsi], ' '
    jne respond_404
id_path_ended:
    cmp rax, [rel intent_count]
    ja respond_404
    call send_intent_response
    ret

# parse_form: returns EAX=1 for exactly one amount and currency field.
parse_form:
    mov qword ptr [rel form_amount_seen], 0
    mov qword ptr [rel form_currency_seen], 0
    mov r14, [rel body_ptr]
    mov r15, [rel body_end]
    cmp r14, r15
    je parse_form_bad

parse_form_scan:
    mov rdx, r14

parse_form_find_separator:
    cmp rdx, r15
    jae parse_form_token_end
    cmp byte ptr [rdx], '&'
    je parse_form_token_end
    inc rdx
    jmp parse_form_find_separator

parse_form_token_end:
    mov [rel form_token_end], rdx
    mov rcx, rdx
    sub rcx, r14
    test rcx, rcx
    jz parse_form_bad
    mov [rel form_token_len], rcx

    # Try amount= at the beginning of this token.
    mov rsi, r14
    mov rcx, [rel form_token_len]
    lea rdi, [rel amount_key]
    mov edx, amount_key_len
    call find_sequence
    cmp rax, r14
    je parse_form_amount

    # Try currency= at the beginning of this token.
    mov rsi, r14
    mov rcx, [rel form_token_len]
    lea rdi, [rel currency_key]
    mov edx, currency_key_len
    call find_sequence
    cmp rax, r14
    je parse_form_currency
    jmp parse_form_bad

parse_form_amount:
    cmp qword ptr [rel form_amount_seen], 0
    jne parse_form_bad
    mov rsi, r14
    add rsi, amount_key_len
    mov r8, [rel form_token_end]
    xor rax, rax
    xor ecx, ecx

parse_form_amount_digits:
    cmp rsi, r8
    jae parse_form_amount_done
    movzx edx, byte ptr [rsi]
    cmp dl, '0'
    jb parse_form_bad
    cmp dl, '9'
    ja parse_form_bad
    inc ecx
    cmp ecx, 8
    ja parse_form_bad
    imul rax, rax, 10
    sub edx, '0'
    add rax, rdx
    inc rsi
    jmp parse_form_amount_digits

parse_form_amount_done:
    test ecx, ecx
    jz parse_form_bad
    test rax, rax
    jz parse_form_bad
    mov [rel current_amount], rax
    mov qword ptr [rel form_amount_seen], 1
    jmp parse_form_token_done

parse_form_currency:
    cmp qword ptr [rel form_currency_seen], 0
    jne parse_form_bad
    cmp qword ptr [rel form_token_len], currency_key_len + 3
    jne parse_form_bad
    lea rsi, [r14 + currency_key_len]
    mov r8, [rel form_token_end]
    lea r9, [rsi + 3]
    cmp r9, r8
    jne parse_form_bad

    movzx edx, byte ptr [rsi]
    movzx ecx, byte ptr [rsi + 1]
    movzx r8d, byte ptr [rsi + 2]
    cmp dl, 'a'
    jb parse_form_bad
    cmp dl, 'z'
    ja parse_form_bad
    cmp cl, 'a'
    jb parse_form_bad
    cmp cl, 'z'
    ja parse_form_bad
    cmp r8b, 'a'
    jb parse_form_bad
    cmp r8b, 'z'
    ja parse_form_bad

    mov byte ptr [rel currency_tmp], dl
    mov byte ptr [rel currency_tmp + 1], cl
    mov byte ptr [rel currency_tmp + 2], r8b
    mov byte ptr [rel currency_tmp + 3], 0
    mov qword ptr [rel form_currency_seen], 1

parse_form_token_done:
    mov rsi, [rel form_token_end]
    cmp rsi, r15
    je parse_form_complete
    cmp byte ptr [rsi], '&'
    jne parse_form_bad
    inc rsi
    cmp rsi, r15
    jae parse_form_bad
    mov r14, rsi
    jmp parse_form_scan

parse_form_complete:
    cmp qword ptr [rel form_amount_seen], 1
    jne parse_form_bad
    cmp qword ptr [rel form_currency_seen], 1
    jne parse_form_bad
    mov eax, 1
    ret

parse_form_bad:
    xor eax, eax
    ret

# parse_idempotency: copies the Idempotency-Key header into current_idem.
# Header name is case-insensitive. Duplicate headers are rejected.
parse_idempotency:
    mov qword ptr [rel current_idem_len], 0
    mov rsi, rbx
    mov rcx, [rel header_len]
    lea rdi, [rel idem_name]
    mov edx, idem_name_len
    call find_sequence_ci
    test rax, rax
    jz parse_idempotency_no_header
    mov [rel hdr_tmp_first], rax
    mov rsi, rax
    inc rsi
    mov r8, rbx
    add r8, [rel header_len]
    cmp rsi, r8
    jae idem_no_duplicate
    mov rcx, r8
    sub rcx, rsi
    lea rdi, [rel idem_name]
    mov edx, idem_name_len
    call find_sequence_ci
    test rax, rax
    jnz parse_idempotency_bad
idem_no_duplicate:
    mov rax, [rel hdr_tmp_first]
    add rax, idem_name_len
    mov rsi, rax
    mov r8, rbx
    add r8, [rel header_len]
idem_skip_leading:
    cmp rsi, r8
    jae parse_idempotency_bad
    movzx eax, byte ptr [rsi]
    cmp al, 32
    je idem_skip_leading_inc
    cmp al, 9
    je idem_skip_leading_inc
    jmp idem_value_start
idem_skip_leading_inc:
    inc rsi
    jmp idem_skip_leading
idem_value_start:
    mov rdx, rsi
idem_find_eol:
    cmp rdx, r8
    jae parse_idempotency_bad
    movzx eax, byte ptr [rdx]
    cmp al, 13
    je idem_eol_found
    cmp al, 10
    je idem_eol_found
    inc rdx
    jmp idem_find_eol
idem_eol_found:
    mov rcx, rdx
idem_trim_trailing:
    cmp rcx, rsi
    jbe idem_trim_done
    movzx eax, byte ptr [rcx - 1]
    cmp al, 32
    je idem_trim_dec
    cmp al, 9
    je idem_trim_dec
    jmp idem_trim_done
idem_trim_dec:
    dec rcx
    jmp idem_trim_trailing
idem_trim_done:
    mov rax, rcx
    sub rax, rsi
    test rax, rax
    jz parse_idempotency_bad
    cmp rax, 255
    ja parse_idempotency_bad
    mov [rel current_idem_len], rax
    lea rdi, [rel current_idem]
    mov rcx, rax
    # RSI already holds value start; copy RCX bytes.
copy_idempotency_trimmed:
    test rcx, rcx
    jz idempotency_copied_ok
    mov al, byte ptr [rsi]
    mov byte ptr [rdi], al
    inc rsi
    inc rdi
    dec rcx
    jmp copy_idempotency_trimmed
idempotency_copied_ok:
    mov eax, 1
parse_idempotency_done:
    ret

parse_idempotency_no_header:
    mov eax, 1
    ret

parse_idempotency_bad:
    xor eax, eax
    ret

# check_idempotency: EAX=0 new, EAX=-1 conflict, EAX=stored sequence replay.
check_idempotency:
    mov rcx, [rel current_idem_len]
    test rcx, rcx
    jz no_matching_idempotency

    mov r11, [rel idem_table_ptr]
    xor r10d, r10d

check_idem_loop:
    cmp r10, IDEM_TABLE_CAP
    jae no_matching_idempotency

    cmp qword ptr [r11 + IDEM_SEQ_OFF], 0
    je check_idem_next

    mov rax, [r11 + IDEM_KEY_LEN_OFF]
    cmp rax, [rel current_idem_len]
    jne check_idem_next

    lea rsi, [rel current_idem]
    mov rdi, r11
    mov rcx, [rel current_idem_len]
    call buffers_equal
    test eax, eax
    jz check_idem_next

    mov rax, [rel current_amount]
    cmp rax, [r11 + IDEM_AMOUNT_OFF]
    jne idempotency_conflict

    mov eax, [rel currency_tmp]
    cmp eax, [r11 + IDEM_CURRENCY_OFF]
    jne idempotency_conflict

    mov rax, [rel current_idem_context]
    cmp rax, [r11 + IDEM_CONTEXT_OFF]
    jne idempotency_conflict

    mov rax, [r11 + IDEM_SEQ_OFF]
    ret

check_idem_next:
    inc r10
    add r11, IDEM_ENTRY_SZ
    jmp check_idem_loop

idempotency_conflict:
    mov rax, -1
    ret

no_matching_idempotency:
    xor eax, eax
    ret

# store_idempotency: write the current key and fingerprint into the first
# free table slot.  Returns RAX=0 on success, RAX=-1 when no slot is free.
store_idempotency:
    mov rcx, [rel current_idem_len]
    test rcx, rcx
    jz store_idem_done

    mov r11, [rel idem_table_ptr]
    xor r10d, r10d

store_idem_loop:
    cmp r10, IDEM_TABLE_CAP
    jae store_idem_full

    cmp qword ptr [r11 + IDEM_SEQ_OFF], 0
    je store_idem_found

    inc r10
    add r11, IDEM_ENTRY_SZ
    jmp store_idem_loop

store_idem_found:
    lea rsi, [rel current_idem]
    mov rdi, r11
    mov rcx, [rel current_idem_len]
    rep movsb

    mov rax, [rel current_idem_len]
    mov [r11 + IDEM_KEY_LEN_OFF], rax

    mov rax, [rel current_amount]
    mov [r11 + IDEM_AMOUNT_OFF], rax

    mov eax, [rel currency_tmp]
    mov [r11 + IDEM_CURRENCY_OFF], eax

    mov rax, [rel current_idem_context]
    mov [r11 + IDEM_CONTEXT_OFF], rax

    mov rax, [rel response_seq]
    mov [r11 + IDEM_SEQ_OFF], rax

    xor eax, eax
    ret

store_idem_full:
    mov rax, -1
    ret

store_idem_done:
    xor eax, eax
    ret

# check_idempotency_capacity: EAX=1 when the active table can accept a new
# keyed request, EAX=0 when the table is full. Requests without a key never
# consume a slot and always pass this check.
check_idempotency_capacity:
    mov rcx, [rel current_idem_len]
    test rcx, rcx
    jz idem_capacity_available

    mov r11, [rel idem_table_ptr]
    xor r10d, r10d
check_idem_capacity_loop:
    cmp r10, IDEM_TABLE_CAP
    jae idem_capacity_full
    cmp qword ptr [r11 + IDEM_SEQ_OFF], 0
    je idem_capacity_available
    inc r10
    add r11, IDEM_ENTRY_SZ
    jmp check_idem_capacity_loop

idem_capacity_available:
    mov eax, 1
    ret

idem_capacity_full:
    xor eax, eax
    ret

# send_intent_response: input RAX is the 1-based PaymentIntent sequence.
send_intent_response:
    mov [rel response_seq], rax
    call build_intent_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_200]
    mov ecx, status_200_len
    call send_json
    ret

build_intent_json:
    mov rax, [rel response_seq]
    mov rbx, rax
    dec rbx
    lea r14, [rel json_buf]

    lea rsi, [rel json_id_prefix]
    mov ecx, json_id_prefix_len
    call copy_to_r14
    mov rax, [rel response_seq]
    call append_uid_to_r14

    lea rsi, [rel json_object_amount]
    mov ecx, json_object_amount_len
    call copy_to_r14
    lea rdi, [rel intent_amounts]
    mov rax, [rdi + rbx * 8]
    call append_u64_to_r14

    lea rsi, [rel json_currency_prefix]
    mov ecx, json_currency_prefix_len
    call copy_to_r14
    lea rdi, [rel intent_currencies]
    lea rsi, [rdi + rbx * 4]
    mov ecx, 3
    call copy_to_r14

    lea rsi, [rel json_status_mid]
    mov ecx, json_status_mid_len
    call copy_to_r14
    mov rax, [rel current_req_id]
    call append_u64_to_r14
    lea rsi, [rel json_status_end]
    mov ecx, json_status_end_len
    call copy_to_r14
    lea rax, [rel json_buf]
    mov rdx, r14
    sub rdx, rax
    mov rax, rdx
    ret

# build_error_json: RSI=type ptr, RCX=type len, RDX=code ptr, R8=code len,
# R9=msg ptr, R10=msg len. Returns RAX=body length in json_buf.
build_error_json:
    push rsi
    push rcx
    lea r14, [rel json_buf]
    lea rsi, [rel err_prefix]
    mov ecx, err_prefix_len
    call copy_to_r14
    pop rcx
    pop rsi
    call copy_to_r14
    lea rsi, [rel err_code_sep]
    mov ecx, err_code_sep_len
    call copy_to_r14
    mov rsi, rdx
    mov rcx, r8
    call copy_to_r14
    lea rsi, [rel err_msg_sep]
    mov ecx, err_msg_sep_len
    call copy_to_r14
    mov rsi, r9
    mov rcx, r10
    call copy_to_r14
    lea rsi, [rel err_req_sep]
    mov ecx, err_req_sep_len
    call copy_to_r14
    mov rax, [rel current_req_id]
    call append_u64_to_r14
    lea rsi, [rel err_suffix]
    mov ecx, err_suffix_len
    call copy_to_r14
    lea rax, [rel json_buf]
    mov rdx, r14
    sub rdx, rax
    mov rax, rdx
    ret

# send_json: status ptr RSI, status len RCX, body ptr RDX, body len R8.
send_json:
    mov [rel send_status_ptr], rsi
    mov [rel send_status_len], rcx
    mov [rel send_body_ptr], rdx
    mov [rel send_body_len], r8
    lea r14, [rel response_buf]

    lea rsi, [rel http_prefix]
    mov ecx, http_prefix_len
    call copy_to_r14
    mov rsi, [rel send_status_ptr]
    mov rcx, [rel send_status_len]
    call copy_to_r14
    lea rsi, [rel http_headers]
    mov ecx, http_headers_len
    call copy_to_r14
    mov rax, [rel send_body_len]
    call append_u64_to_r14
    lea rsi, [rel req_id_hdr_prefix]
    mov ecx, req_id_hdr_prefix_len
    call copy_to_r14
    mov rax, [rel current_req_id]
    call append_u64_to_r14
    lea rsi, [rel http_suffix]
    mov ecx, http_suffix_len
    call copy_to_r14
    mov rsi, [rel send_body_ptr]
    mov rcx, [rel send_body_len]
    call copy_to_r14

    lea rsi, [rel response_buf]
    mov rdx, r14
    sub rdx, rsi
    mov rdi, r13
    call write_all
    ret

copy_to_r14:
    mov rdi, r14
    rep movsb
    mov r14, rdi
    ret

append_u64_to_r14:
    lea rdi, [rel num_buf + 32]
    xor ecx, ecx
    mov r10d, 10
    test rax, rax
    jnz append_digits
    dec rdi
    mov byte ptr [rdi], '0'
    inc ecx
    jmp append_digits_done

append_digits:
    xor edx, edx
    div r10
    add dl, '0'
    dec rdi
    mov byte ptr [rdi], dl
    inc ecx
    test rax, rax
    jnz append_digits

append_digits_done:
    mov rsi, rdi
    mov rdi, r14
    rep movsb
    mov r14, rdi
    ret

# append_uid_to_r14: append the 16-character opaque UID token for slot RAX.
# The public token combines the per-process seed with the private table slot.
append_uid_to_r14:
    or rax, [rel uid_seed]
    mov r10d, UID_HEX_LEN
    lea rdi, [rel uid_hex_chars]
append_uid_loop:
    mov rcx, rax
    shr rcx, 60
    and ecx, 0xf
    mov dl, byte ptr [rdi + rcx]
    mov byte ptr [r14], dl
    inc r14
    shl rax, 4
    dec r10
    jnz append_uid_loop
    ret

buffers_equal:
    # RSI and RDI point to buffers; RCX is their length.
    repe cmpsb
    sete al
    movzx eax, al
    ret

# find_sequence: RSI buffer, RCX length, RDI pattern, RDX pattern length.
# Returns RAX=match pointer, or zero.
find_sequence:
    mov r8, rsi
    mov r9, rcx
    mov r11, rdi
    xor r10, r10
    test rdx, rdx
    jz find_not_found

find_scan:
    cmp r10, r9
    jae find_not_found
    mov rax, r9
    sub rax, r10
    cmp rax, rdx
    jb find_not_found
    lea rsi, [r8 + r10]
    mov rdi, r11
    mov rcx, rdx
    repe cmpsb
    je find_found
    inc r10
    jmp find_scan

find_found:
    lea rax, [r8 + r10]
    ret

find_not_found:
    xor eax, eax
    ret

# find_sequence_ci: same as find_sequence but ASCII case-insensitive.
find_sequence_ci:
    mov r8, rsi
    mov r9, rcx
    mov r11, rdi
    xor r10, r10
    test rdx, rdx
    jz find_ci_not_found
find_ci_scan:
    cmp r10, r9
    jae find_ci_not_found
    mov rax, r9
    sub rax, r10
    cmp rax, rdx
    jb find_ci_not_found
    lea rsi, [r8 + r10]
    mov rdi, r11
    mov rcx, rdx
find_ci_cmp:
    test rcx, rcx
    jz find_ci_found
    mov al, byte ptr [rsi]
    mov ah, byte ptr [rdi]
    cmp al, 65
    jb find_ci_no_lower_al
    cmp al, 90
    ja find_ci_no_lower_al
    add al, 32
find_ci_no_lower_al:
    cmp ah, 65
    jb find_ci_no_lower_ah
    cmp ah, 90
    ja find_ci_no_lower_ah
    add ah, 32
find_ci_no_lower_ah:
    cmp al, ah
    jne find_ci_next
    inc rsi
    inc rdi
    dec rcx
    jmp find_ci_cmp
find_ci_next:
    inc r10
    jmp find_ci_scan
find_ci_found:
    lea rax, [r8 + r10]
    ret
find_ci_not_found:
    xor eax, eax
    ret

respond_400:
    lea rsi, [rel type_invalid]
    mov ecx, type_invalid_len
    lea rdx, [rel code_invalid]
    mov r8d, code_invalid_len
    lea r9, [rel msg_invalid]
    mov r10d, msg_invalid_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_400]
    mov ecx, status_400_len
    call send_json
    ret

respond_idem_conflict:
    lea rsi, [rel type_idem]
    mov ecx, type_idem_len
    lea rdx, [rel code_idem]
    mov r8d, code_idem_len
    lea r9, [rel msg_idem]
    mov r10d, msg_idem_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_400]
    mov ecx, status_400_len
    call send_json
    ret

respond_table_full:
    lea rsi, [rel type_storage]
    mov ecx, type_storage_len
    lea rdx, [rel code_storage]
    mov r8d, code_storage_len
    lea r9, [rel msg_storage]
    mov r10d, msg_storage_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_507]
    mov ecx, status_507_len
    call send_json
    ret

respond_401:
    lea rsi, [rel type_auth]
    mov ecx, type_auth_len
    lea rdx, [rel code_auth]
    mov r8d, code_auth_len
    lea r9, [rel msg_auth]
    mov r10d, msg_auth_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_401]
    mov ecx, status_401_len
    call send_json
    ret

respond_404:
    lea rsi, [rel type_notfound]
    mov ecx, type_notfound_len
    lea rdx, [rel code_notfound]
    mov r8d, code_notfound_len
    lea r9, [rel msg_notfound]
    mov r10d, msg_notfound_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_404]
    mov ecx, status_404_len
    call send_json
    ret

respond_413:
    lea rsi, [rel type_toolarge]
    mov ecx, type_toolarge_len
    lea rdx, [rel code_toolarge]
    mov r8d, code_toolarge_len
    lea r9, [rel msg_toolarge]
    mov r10d, msg_toolarge_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_413]
    mov ecx, status_413_len
    call send_json
    ret

write_all:
    test rdx, rdx
    jz write_all_done
write_all_loop:
    mov eax, 1
    syscall
    cmp rax, -4           # EINTR
    je write_all_loop
    test rax, rax
    jz write_all_done
    js write_all_done
    sub rdx, rax
    add rsi, rax
    jnz write_all_loop
write_all_done:
    ret

# --- Users / Accounts / Ledger handlers ---

# decode_uid_token: parse a 16-character hex UID token at RSI and return the
# private table slot in RAX. R8 is the end of the containing request/value.
# Returns zero for malformed, wrong-boot, or zero-slot tokens; RSI advances on
# success so callers can validate route suffixes.
decode_uid_token:
    xor rax, rax
    xor r10d, r10d
decode_uid_loop:
    cmp r10, UID_HEX_LEN
    jae decode_uid_done
    cmp rsi, r8
    jae decode_uid_bad
    movzx edx, byte ptr [rsi]
    cmp dl, '0'
    jb decode_uid_alpha
    cmp dl, '9'
    ja decode_uid_alpha
    sub edx, '0'
    jmp decode_uid_nibble
decode_uid_alpha:
    cmp dl, 'a'
    jb decode_uid_bad
    cmp dl, 'f'
    ja decode_uid_bad
    sub edx, 'a' - 10
decode_uid_nibble:
    shl rax, 4
    or rax, rdx
    inc rsi
    inc r10
    jmp decode_uid_loop
decode_uid_done:
    mov rcx, rax
    and rcx, -32
    cmp rcx, [rel uid_seed]
    jne decode_uid_bad
    and rax, 31
    test rax, rax
    jz decode_uid_bad
    ret
decode_uid_bad:
    xor eax, eax
    ret

# Extractors validate the public prefix in the route dispatcher, then decode
# the token. They return zero on malformed input; callers own the response and
# must not fall through after a failed decode.
extract_user_id:
    call decode_uid_token
    test rax, rax
    jz extract_user_bad
    ret
extract_user_bad:
    xor eax, eax
    ret

extract_acct_id:
    call decode_uid_token
    test rax, rax
    jz extract_acct_bad
    ret
extract_acct_bad:
    xor eax, eax
    ret

extract_txn_id:
    call decode_uid_token
    test rax, rax
    jz extract_txn_bad
    ret
extract_txn_bad:
    xor eax, eax
    ret

# parse_form_value: parse form body for key=<value>.
# RDI = key pattern ptr, RDX = key pattern len.
# Sets form_value_buf and form_value_len. Returns EAX=1 on success, 0 on bad.
parse_form_value:
    # find_sequence advances RDI while comparing a non-matching token.
    # Preserve the requested key so later form fields use its original start.
    push r12
    mov r12, rdi
    mov qword ptr [rel form_value_len], 0
    mov r14, [rel body_ptr]
    mov r15, [rel body_end]
    cmp r14, r15
    je parse_form_value_bad

parse_fv_scan:
    mov rbx, r14

parse_fv_find_sep:
    cmp rbx, r15
    jae parse_fv_token_end
    cmp byte ptr [rbx], '&'
    je parse_fv_token_end
    inc rbx
    jmp parse_fv_find_sep

parse_fv_token_end:
    # Try matching key at start of this token.
    mov rcx, rbx
    sub rcx, r14
    cmp rcx, rdx
    jb parse_fv_next_token
    mov rsi, r14
    mov rdi, r12
    push rdx
    call find_sequence
    pop rdx
    cmp rax, r14
    jne parse_fv_next_token

    # Key matched: extract value after key.
    lea rsi, [r14 + rdx]
    mov r8, rbx
    xor ecx, ecx
parse_fv_val_len:
    cmp rsi, r8
    jae parse_fv_val_len_done
    inc rcx
    inc rsi
    jmp parse_fv_val_len
parse_fv_val_len_done:
    test rcx, rcx
    jz parse_form_value_bad
    cmp rcx, 255
    ja parse_form_value_bad
    mov [rel form_value_len], rcx
    lea rdi, [rel form_value_buf]
    mov rsi, r14
    add rsi, rdx
parse_fv_copy:
    test rcx, rcx
    jz parse_fv_copied
    mov al, byte ptr [rsi]
    mov byte ptr [rdi], al
    inc rsi
    inc rdi
    dec rcx
    jmp parse_fv_copy
parse_fv_copied:
    pop r12
    mov eax, 1
    ret

parse_fv_next_token:
    cmp rbx, r15
    je parse_form_value_bad
    cmp byte ptr [rbx], '&'
    jne parse_form_value_bad
    lea r14, [rbx + 1]
    cmp r14, r15
    jae parse_form_value_bad
    jmp parse_fv_scan

parse_form_value_bad:
    pop r12
    xor eax, eax
    ret

# --- Route: GET /v1/accounts/acct_<uid>[/balance] ---
route_get_account:
    lea rsi, [rbx + get_accounts_route_len]
    mov r8, rbx
    add r8, [rel request_len]
    call extract_acct_id
    test rax, rax
    jz respond_404
    cmp rax, 1
    jb respond_404
    cmp rax, [rel acct_count]
    ja respond_404
    mov [rel account_id], rax
    # Check for /balance suffix.
    cmp rsi, r8
    jae respond_404
    cmp byte ptr [rsi], '/'
    je route_get_account_check_balance
    cmp byte ptr [rsi], ' '
    je retrieve_account
    jmp respond_404
route_get_account_check_balance:
    mov r14, rsi
    lea rdi, [rel balance_suffix]
    mov edx, balance_suffix_len
    mov rcx, r8
    sub rcx, rsi
    call find_sequence
    cmp rax, r14
    je retrieve_account_balance
    jmp respond_404

# --- POST /v1/users ---
create_user:
    # Validate Content-Type.
    mov rsi, rbx
    mov rcx, [rel header_len]
    lea rdi, [rel ct_name]
    mov edx, ct_name_len
    call find_sequence_ci
    test rax, rax
    jz respond_400
    mov [rel hdr_tmp_first], rax
    mov rsi, rax
    inc rsi
    mov r8, rbx
    add r8, [rel header_len]
    cmp rsi, r8
    jae cu_ct_no_dup
    mov rcx, r8
    sub rcx, rsi
    lea rdi, [rel ct_name]
    mov edx, ct_name_len
    call find_sequence_ci
    test rax, rax
    jnz respond_400
cu_ct_no_dup:
    mov rax, [rel hdr_tmp_first]
    add rax, ct_name_len
    mov rsi, rax
    mov r8, rbx
    add r8, [rel header_len]
cu_ct_skip:
    cmp rsi, r8
    jae respond_400
    movzx eax, byte ptr [rsi]
    cmp al, 32
    je cu_ct_skip_inc
    cmp al, 9
    je cu_ct_skip_inc
    jmp cu_ct_val
cu_ct_skip_inc:
    inc rsi
    jmp cu_ct_skip
cu_ct_val:
    mov rdx, rsi
cu_ct_eol:
    cmp rdx, r8
    jae respond_400
    movzx eax, byte ptr [rdx]
    cmp al, 13
    je cu_ct_eol_found
    cmp al, 10
    je cu_ct_eol_found
    inc rdx
    jmp cu_ct_eol
cu_ct_eol_found:
    mov rcx, rdx
cu_ct_trim:
    cmp rcx, rsi
    jbe cu_ct_done
    movzx eax, byte ptr [rcx - 1]
    cmp al, 32
    je cu_ct_trim_dec
    cmp al, 9
    je cu_ct_trim_dec
    jmp cu_ct_done
cu_ct_trim_dec:
    dec rcx
    jmp cu_ct_trim
cu_ct_done:
    mov rax, rcx
    sub rax, rsi
    cmp rax, ct_expected_len
    jne respond_400
    mov rcx, rax
    lea rdi, [rel ct_expected]
    call buffers_equal
    test eax, eax
    jz respond_400

    # Parse form for email=<value>.
    mov rax, rbx
    add rax, [rel header_len]
    mov [rel body_ptr], rax
    mov rdx, rbx
    add rdx, [rel request_len]
    mov [rel body_end], rdx
    lea rdi, [rel email_key]
    mov edx, email_key_len
    call parse_form_value
    test eax, eax
    jz cu_missing_email
    cmp qword ptr [rel form_value_len], USER_EMAIL_LEN
    ja cu_email_too_long

    # Reject unknown form fields (only email= allowed).
    mov qword ptr [rel cu_email_seen], 0
    mov r14, [rel body_ptr]
    mov r15, [rel body_end]
cu_scan_fields:
    cmp r14, r15
    je cu_field_check_done
    mov rdx, r14
cu_find_sep:
    cmp rdx, r15
    jae cu_field_end
    cmp byte ptr [rdx], '&'
    je cu_field_end
    inc rdx
    jmp cu_find_sep
cu_field_end:
    mov rcx, rdx
    sub rcx, r14
    lea rdi, [rel email_key]
    push rdx
    mov rsi, r14
    mov edx, email_key_len
    call find_sequence
    pop rdx
    cmp rax, r14
    jne cu_unknown_field
    cmp qword ptr [rel cu_email_seen], 0
    jne cu_unknown_field
    mov qword ptr [rel cu_email_seen], 1
    jmp cu_field_next
cu_unknown_field:
    # Unknown field.
    jmp respond_400
cu_field_next:
    cmp rdx, r15
    jae cu_field_check_done
    lea r14, [rdx + 1]
    jmp cu_scan_fields
cu_field_check_done:

    # Check capacity.
    mov rbx, [rel user_count]
    cmp rbx, USER_TABLE_CAP
    jae cu_table_full

    # Check for duplicate email.
    mov r11, [rel form_value_len]
    xor r10d, r10d
cu_dup_loop:
    cmp r10, rbx
    jae cu_store
    # Compute slot offset = r10 * USER_EMAIL_LEN.
    mov rax, r10
    imul rax, USER_EMAIL_LEN
    lea rdi, [rel user_emails]
    add rdi, rax
    # Compute slot length: find NUL in slot.
    mov rsi, rdi
    xor ecx, ecx
cu_slot_len_loop:
    cmp ecx, USER_EMAIL_LEN
    jae cu_slot_len_done
    movzx eax, byte ptr [rdi]
    test al, al
    jz cu_slot_len_done
    inc rcx
    inc rdi
    jmp cu_slot_len_loop
cu_slot_len_done:
    cmp rcx, r11
    jne cu_dup_next
    push r10
    push rcx
    lea rdi, [rel form_value_buf]
    call buffers_equal
    pop rcx
    pop r10
    test eax, eax
    jnz cu_email_taken
cu_dup_next:
    inc r10
    jmp cu_dup_loop

cu_store:
    # Copy email into user_emails[rbx].
    # Compute offset = rbx * 120.
    mov rax, rbx
    imul rax, USER_EMAIL_LEN
    lea rdi, [rel user_emails]
    add rdi, rax
    # Zero the slot first (rbx=user_count, rdi=slot pointer).
    push rcx
    push rdi
    mov ecx, USER_EMAIL_LEN
    xor eax, eax
cu_zero_slot:
    test ecx, ecx
    jz cu_zero_done
    mov byte ptr [rdi], al
    inc rdi
    dec ecx
    jmp cu_zero_slot
cu_zero_done:
    pop rdi
    pop rcx
    lea rsi, [rel form_value_buf]
    mov rcx, [rel form_value_len]
    mov rcx, [rel form_value_len]
cu_copy_email:
    test rcx, rcx
    jz cu_email_copied
    mov al, byte ptr [rsi]
    mov byte ptr [rdi], al
    inc rsi
    inc rdi
    dec rcx
    jmp cu_copy_email
cu_email_copied:
    inc qword ptr [rel user_count]

    # Build JSON with an opaque user UID.
    lea r14, [rel json_buf]
    lea rsi, [rel json_user_id_prefix]
    mov ecx, json_user_id_prefix_len
    call copy_to_r14
    mov rax, [rel user_count]
    call append_uid_to_r14
    lea rsi, [rel json_user_object_email]
    mov ecx, json_user_object_email_len
    call copy_to_r14
    lea rsi, [rel form_value_buf]
    mov rcx, [rel form_value_len]
    call copy_to_r14
    lea rsi, [rel json_user_email_reqid_mid]
    mov ecx, json_user_email_reqid_mid_len
    call copy_to_r14
    mov rax, [rel current_req_id]
    call append_u64_to_r14
    lea rsi, [rel json_status_end]
    mov ecx, json_status_end_len
    call copy_to_r14
    lea rax, [rel json_buf]
    mov rdx, r14
    sub rdx, rax
    mov r8, rdx
    lea rdx, [rel json_buf]
    lea rsi, [rel status_201]
    mov ecx, status_201_len
    call send_json
    ret

cu_missing_email:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_param_error]
    mov r8d, code_param_error_len
    lea r9, [rel msg_missing_email]
    mov r10d, msg_missing_email_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_400]
    mov ecx, status_400_len
    call send_json
    ret

cu_email_taken:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_param_error]
    mov r8d, code_param_error_len
    lea r9, [rel msg_email_taken]
    mov r10d, msg_email_taken_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_409]
    mov ecx, status_409_len
    call send_json
    ret

cu_email_too_long:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_param_error]
    mov r8d, code_param_error_len
    lea r9, [rel msg_email_too_long]
    mov r10d, msg_email_too_long_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_400]
    mov ecx, status_400_len
    call send_json
    ret

cu_table_full:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_param_error]
    mov r8d, code_param_error_len
    lea r9, [rel msg_table_full]
    mov r10d, msg_table_full_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_507]
    mov ecx, status_507_len
    call send_json
    ret

# --- POST /v1/accounts ---
create_account:
    # Validate Content-Type.
    mov rsi, rbx
    mov rcx, [rel header_len]
    lea rdi, [rel ct_name]
    mov edx, ct_name_len
    call find_sequence_ci
    test rax, rax
    jz respond_400
    mov [rel hdr_tmp_first], rax
    mov rsi, rax
    inc rsi
    mov r8, rbx
    add r8, [rel header_len]
    cmp rsi, r8
    jae ca_ct_no_dup
    mov rcx, r8
    sub rcx, rsi
    lea rdi, [rel ct_name]
    mov edx, ct_name_len
    call find_sequence_ci
    test rax, rax
    jnz respond_400
ca_ct_no_dup:
    mov rax, [rel hdr_tmp_first]
    add rax, ct_name_len
    mov rsi, rax
    mov r8, rbx
    add r8, [rel header_len]
ca_ct_skip:
    cmp rsi, r8
    jae respond_400
    movzx eax, byte ptr [rsi]
    cmp al, 32
    je ca_ct_skip_inc
    cmp al, 9
    je ca_ct_skip_inc
    jmp ca_ct_val
ca_ct_skip_inc:
    inc rsi
    jmp ca_ct_skip
ca_ct_val:
    mov rdx, rsi
ca_ct_eol:
    cmp rdx, r8
    jae respond_400
    movzx eax, byte ptr [rdx]
    cmp al, 13
    je ca_ct_eol_found
    cmp al, 10
    je ca_ct_eol_found
    inc rdx
    jmp ca_ct_eol
ca_ct_eol_found:
    mov rcx, rdx
ca_ct_trim:
    cmp rcx, rsi
    jbe ca_ct_done
    movzx eax, byte ptr [rcx - 1]
    cmp al, 32
    je ca_ct_trim_dec
    cmp al, 9
    je ca_ct_trim_dec
    jmp ca_ct_done
ca_ct_trim_dec:
    dec rcx
    jmp ca_ct_trim
ca_ct_done:
    mov rax, rcx
    sub rax, rsi
    cmp rax, ct_expected_len
    jne respond_400
    mov rcx, rax
    lea rdi, [rel ct_expected]
    call buffers_equal
    test eax, eax
    jz respond_400

    # Parse form body.
    mov rax, rbx
    add rax, [rel header_len]
    mov [rel body_ptr], rax
    mov rdx, rbx
    add rdx, [rel request_len]
    mov [rel body_end], rdx

    # Parse user_id= field.
    lea rdi, [rel user_id_key]
    mov edx, user_id_key_len
    call parse_form_value
    test eax, eax
    jz ca_missing_user_id
    # Validate user_id = usr_<16 lowercase hex characters>.
    cmp qword ptr [rel form_value_len], user_uid_prefix_len + UID_HEX_LEN
    jne ca_bad_user_id
    lea rsi, [rel form_value_buf]
    lea rdi, [rel user_uid_prefix]
    mov rcx, user_uid_prefix_len
    call buffers_equal
    test eax, eax
    jz ca_bad_user_id
    # Decode the opaque user UID to its private table slot.
    lea rsi, [rel form_value_buf]
    add rsi, user_uid_prefix_len
    lea r8, [rsi + UID_HEX_LEN]
    call decode_uid_token
    test rax, rax
    jz ca_bad_user_id
    cmp rax, [rel user_count]
    ja ca_bad_user_id
    mov [rel user_number], rax

    # Parse currency= field.
    lea rdi, [rel currency_key]
    mov edx, currency_key_len
    call parse_form_value
    test eax, eax
    jz ca_missing_currency
    # Validate currency = usd.
    cmp qword ptr [rel form_value_len], 3
    jne ca_bad_currency
    lea rsi, [rel form_value_buf]
    cmp byte ptr [rsi], 'u'
    jne ca_bad_currency
    cmp byte ptr [rsi + 1], 's'
    jne ca_bad_currency
    cmp byte ptr [rsi + 2], 'd'
    jne ca_bad_currency

    # Reject duplicate and unknown form fields.
    mov qword ptr [rel ca_user_id_seen], 0
    mov qword ptr [rel ca_currency_seen], 0
    mov r14, [rel body_ptr]
    mov r15, [rel body_end]
ca_scan_fields:
    cmp r14, r15
    je ca_field_check_done
    mov rdx, r14
ca_find_sep:
    cmp rdx, r15
    jae ca_field_end
    cmp byte ptr [rdx], '&'
    je ca_field_end
    inc rdx
    jmp ca_find_sep
ca_field_end:
    mov rsi, r14
    lea rdi, [rel user_id_key]
    mov rcx, rdx
    sub rcx, r14
    push rdx
    mov edx, user_id_key_len
    call find_sequence
    pop rdx
    cmp rax, r14
    jne ca_try_currency_field
    cmp qword ptr [rel ca_user_id_seen], 0
    jne respond_400
    mov qword ptr [rel ca_user_id_seen], 1
    jmp ca_field_next
ca_try_currency_field:
    mov rsi, r14
    lea rdi, [rel currency_key]
    mov rcx, rdx
    sub rcx, r14
    push rdx
    mov edx, currency_key_len
    call find_sequence
    pop rdx
    cmp rax, r14
    jne respond_400
    cmp qword ptr [rel ca_currency_seen], 0
    jne respond_400
    mov qword ptr [rel ca_currency_seen], 1
ca_field_next:
    cmp rdx, r15
    jae ca_field_check_done
    lea r14, [rdx + 1]
    jmp ca_scan_fields
ca_field_check_done:

    # Check capacity.
    mov rbx, [rel acct_count]
    cmp rbx, ACCT_TABLE_CAP
    jae ca_table_full
    mov r10, [rel txn_count]
    cmp r10, TXN_TABLE_CAP
    jae ca_table_full

    # Store account.
    lea rdi, [rel acct_user_ids]
    mov rax, [rel user_number]
    mov [rdi + rbx * 8], rax
    lea rdi, [rel acct_currencies]
    mov dword ptr [rdi + rbx * 4], 0x00647375  # "usd\0" little-endian
    lea rdi, [rel acct_balances]
    mov qword ptr [rdi + rbx * 8], 0
    inc qword ptr [rel acct_count]

    # Create ledger entry: txn_<uid>, account=acct_<uid>, amount=0, type=account_opened.
    mov r10, [rel txn_count]
    lea rdi, [rel txn_account_ids]
    mov rax, [rel acct_count]
    mov [rdi + r10 * 8], rax
    lea rdi, [rel txn_amounts]
    mov qword ptr [rdi + r10 * 8], 0
    lea rdi, [rel txn_types]
    mov qword ptr [rdi + r10 * 8], TXN_TYPE_OPENED
    inc qword ptr [rel txn_count]

    # Build JSON with opaque account and user UIDs.
    lea r14, [rel json_buf]
    lea rsi, [rel json_acct_id_prefix]
    mov ecx, json_acct_id_prefix_len
    call copy_to_r14
    mov rax, [rel acct_count]
    call append_uid_to_r14
    lea rsi, [rel json_acct_object_userid]
    mov ecx, json_acct_object_userid_len
    call copy_to_r14
    mov rax, [rel user_number]
    call append_uid_to_r14
    lea rsi, [rel json_acct_currency_mid]
    mov ecx, json_acct_currency_mid_len
    call copy_to_r14
    lea rsi, [rel form_value_buf]
    mov ecx, 3
    call copy_to_r14
    lea rsi, [rel json_acct_balance_mid]
    mov ecx, json_acct_balance_mid_len
    call copy_to_r14
    lea rdi, [rel acct_balances]
    mov rax, [rdi + rbx * 8]
    call append_u64_to_r14
    lea rsi, [rel json_acct_reqid_mid]
    mov ecx, json_acct_reqid_mid_len
    call copy_to_r14
    mov rax, [rel current_req_id]
    call append_u64_to_r14
    lea rsi, [rel json_status_end]
    mov ecx, json_status_end_len
    call copy_to_r14
    lea rax, [rel json_buf]
    mov rdx, r14
    sub rdx, rax
    mov r8, rdx
    lea rdx, [rel json_buf]
    lea rsi, [rel status_201]
    mov ecx, status_201_len
    call send_json
    ret

ca_missing_user_id:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_param_error]
    mov r8d, code_param_error_len
    lea r9, [rel msg_missing_user_id]
    mov r10d, msg_missing_user_id_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_400]
    mov ecx, status_400_len
    call send_json
    ret

ca_bad_user_id:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_param_error]
    mov r8d, code_param_error_len
    lea r9, [rel msg_user_not_found]
    mov r10d, msg_user_not_found_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_404]
    mov ecx, status_404_len
    call send_json
    ret

ca_missing_currency:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_param_error]
    mov r8d, code_param_error_len
    lea r9, [rel msg_missing_currency]
    mov r10d, msg_missing_currency_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_400]
    mov ecx, status_400_len
    call send_json
    ret

ca_bad_currency:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_param_error]
    mov r8d, code_param_error_len
    lea r9, [rel msg_invalid_currency]
    mov r10d, msg_invalid_currency_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_400]
    mov ecx, status_400_len
    call send_json
    ret

ca_table_full:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_param_error]
    mov r8d, code_param_error_len
    lea r9, [rel msg_table_full]
    mov r10d, msg_table_full_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_507]
    mov ecx, status_507_len
    call send_json
    ret

# --- GET /v1/accounts/acct_<uid> ---
retrieve_account:
    # Build JSON with opaque account and user UIDs.
    mov rax, [rel account_id]
    dec rax
    mov rbx, rax
    lea r14, [rel json_buf]
    lea rsi, [rel json_acct_id_prefix]
    mov ecx, json_acct_id_prefix_len
    call copy_to_r14
    mov rax, [rel account_id]
    call append_uid_to_r14
    lea rsi, [rel json_acct_object_userid]
    mov ecx, json_acct_object_userid_len
    call copy_to_r14
    lea rdi, [rel acct_user_ids]
    mov rax, [rdi + rbx * 8]
    call append_uid_to_r14
    lea rsi, [rel json_acct_currency_mid]
    mov ecx, json_acct_currency_mid_len
    call copy_to_r14
    lea rdi, [rel acct_currencies]
    lea rsi, [rdi + rbx * 4]
    mov ecx, 3
    call copy_to_r14
    lea rsi, [rel json_acct_balance_mid]
    mov ecx, json_acct_balance_mid_len
    call copy_to_r14
    lea rdi, [rel acct_balances]
    mov rax, [rdi + rbx * 8]
    call append_u64_to_r14
    lea rsi, [rel json_acct_reqid_mid]
    mov ecx, json_acct_reqid_mid_len
    call copy_to_r14
    mov rax, [rel current_req_id]
    call append_u64_to_r14
    lea rsi, [rel json_status_end]
    mov ecx, json_status_end_len
    call copy_to_r14
    lea rax, [rel json_buf]
    mov rdx, r14
    sub rdx, rax
    mov r8, rdx
    lea rdx, [rel json_buf]
    lea rsi, [rel status_200]
    mov ecx, status_200_len
    call send_json
    ret

# --- GET /v1/accounts/acct_<uid>/balance ---
retrieve_account_balance:
    mov rax, [rel account_id]
    dec rax
    mov rbx, rax
    lea r14, [rel json_buf]
    lea rsi, [rel json_balance_value]
    mov ecx, json_balance_value_len
    call copy_to_r14
    lea rdi, [rel acct_balances]
    mov rax, [rdi + rbx * 8]
    call append_u64_to_r14
    lea rsi, [rel json_balance_reqid_mid]
    mov ecx, json_balance_reqid_mid_len
    call copy_to_r14
    mov rax, [rel current_req_id]
    call append_u64_to_r14
    lea rsi, [rel json_status_end]
    mov ecx, json_status_end_len
    call copy_to_r14
    lea rax, [rel json_buf]
    mov rdx, r14
    sub rdx, rax
    mov r8, rdx
    lea rdx, [rel json_buf]
    lea rsi, [rel status_200]
    mov ecx, status_200_len
    call send_json
    ret

# --- GET /v1/transactions/txn_<uid> ---
retrieve_transaction:
    lea rsi, [rbx + get_txns_route_len]
    mov r8, rbx
    add r8, [rel request_len]
    call extract_txn_id
    cmp rax, 1
    jb respond_404
    cmp rax, [rel txn_count]
    ja respond_txn_not_found
    cmp rax, TXN_TABLE_CAP
    ja respond_txn_not_found
    mov rbx, rax
    dec rbx
    lea rdi, [rel txn_types]
    mov rax, [rdi + rbx * 8]
    cmp rax, 2
    je retrieve_txn_transfer
    cmp rax, 3
    je retrieve_txn_withdrawal
    cmp rax, 4
    je retrieve_txn_reversal
    cmp rax, 5
    je retrieve_txn_deposit
    # Default: type 1 account_opened.
    lea r14, [rel json_buf]
    lea rsi, [rel json_txn_id_prefix]
    mov ecx, json_txn_id_prefix_len
    call copy_to_r14
    lea rax, [rbx + 1]
    call append_uid_to_r14
    lea rsi, [rel json_txn_object_acctid]
    mov ecx, json_txn_object_acctid_len
    call copy_to_r14
    lea rdi, [rel txn_account_ids]
    mov rax, [rdi + rbx * 8]
    call append_uid_to_r14
    lea rsi, [rel json_txn_amount_mid]
    mov ecx, json_txn_amount_mid_len
    call copy_to_r14
    lea rdi, [rel txn_amounts]
    mov rax, [rdi + rbx * 8]
    call append_u64_to_r14
    lea rsi, [rel json_txn_type_mid]
    mov ecx, json_txn_type_mid_len
    call copy_to_r14
    lea rdi, [rel txn_types]
    mov rax, [rdi + rbx * 8]
    cmp rax, TXN_TYPE_OPENED
    je txn_type_opened
    # Preserve forward compatibility for ledger types added later.
    call append_u64_to_r14
    jmp txn_type_done
txn_type_opened:
    lea rsi, [rel json_txn_type_opened]
    mov ecx, json_txn_type_opened_len
    call copy_to_r14
txn_type_done:
    lea rsi, [rel json_txn_reqid_mid]
    mov ecx, json_txn_reqid_mid_len
    call copy_to_r14
    mov rax, [rel current_req_id]
    call append_u64_to_r14
    lea rsi, [rel json_status_end]
    mov ecx, json_status_end_len
    call copy_to_r14
    lea rax, [rel json_buf]
    mov rdx, r14
    sub rdx, rax
    mov r8, rdx
    lea rdx, [rel json_buf]
    lea rsi, [rel status_200]
    mov ecx, status_200_len
    call send_json
    ret

retrieve_txn_transfer:
    lea r14, [rel json_buf]
    lea rsi, [rel json_txn_id_prefix]
    mov ecx, json_txn_id_prefix_len
    call copy_to_r14
    lea rax, [rbx + 1]
    call append_uid_to_r14
    lea rsi, [rel json_transfer_sender_mid]
    mov ecx, json_transfer_sender_mid_len
    call copy_to_r14
    lea rdi, [rel txn_account_ids]
    mov rax, [rdi + rbx * 8]
    call append_uid_to_r14
    lea rsi, [rel json_transfer_recipient_mid]
    mov ecx, json_transfer_recipient_mid_len
    call copy_to_r14
    lea rdi, [rel txn_extra]
    mov rax, [rdi + rbx * 8]
    call append_uid_to_r14
    lea rsi, [rel json_txn_amount_mid]
    mov ecx, json_txn_amount_mid_len
    call copy_to_r14
    lea rdi, [rel txn_amounts]
    mov rax, [rdi + rbx * 8]
    call append_u64_to_r14
    lea rsi, [rel json_txn_type_mid]
    mov ecx, json_txn_type_mid_len
    call copy_to_r14
    lea rsi, [rel json_txn_type_transfer]
    mov ecx, json_txn_type_transfer_len
    call copy_to_r14
    lea rsi, [rel json_txn_reqid_mid]
    mov ecx, json_txn_reqid_mid_len
    call copy_to_r14
    mov rax, [rel current_req_id]
    call append_u64_to_r14
    lea rsi, [rel json_status_end]
    mov ecx, json_status_end_len
    call copy_to_r14
    lea rax, [rel json_buf]
    mov rdx, r14
    sub rdx, rax
    mov r8, rdx
    lea rdx, [rel json_buf]
    lea rsi, [rel status_200]
    mov ecx, status_200_len
    call send_json
    ret

retrieve_txn_withdrawal:
    lea r14, [rel json_buf]
    lea rsi, [rel json_txn_id_prefix]
    mov ecx, json_txn_id_prefix_len
    call copy_to_r14
    lea rax, [rbx + 1]
    call append_uid_to_r14
    lea rsi, [rel json_txn_object_acctid]
    mov ecx, json_txn_object_acctid_len
    call copy_to_r14
    lea rdi, [rel txn_account_ids]
    mov rax, [rdi + rbx * 8]
    call append_uid_to_r14
    lea rsi, [rel json_txn_amount_mid]
    mov ecx, json_txn_amount_mid_len
    call copy_to_r14
    lea rdi, [rel txn_amounts]
    mov rax, [rdi + rbx * 8]
    call append_u64_to_r14
    lea rsi, [rel json_txn_type_mid]
    mov ecx, json_txn_type_mid_len
    call copy_to_r14
    lea rsi, [rel json_txn_type_withdrawal]
    mov ecx, json_txn_type_withdrawal_len
    call copy_to_r14
    lea rsi, [rel json_txn_reqid_mid]
    mov ecx, json_txn_reqid_mid_len
    call copy_to_r14
    mov rax, [rel current_req_id]
    call append_u64_to_r14
    lea rsi, [rel json_status_end]
    mov ecx, json_status_end_len
    call copy_to_r14
    lea rax, [rel json_buf]
    mov rdx, r14
    sub rdx, rax
    mov r8, rdx
    lea rdx, [rel json_buf]
    lea rsi, [rel status_200]
    mov ecx, status_200_len
    call send_json
    ret

retrieve_txn_deposit:
    lea r14, [rel json_buf]
    lea rsi, [rel json_txn_id_prefix]
    mov ecx, json_txn_id_prefix_len
    call copy_to_r14
    lea rax, [rbx + 1]
    call append_uid_to_r14
    lea rsi, [rel json_txn_object_acctid]
    mov ecx, json_txn_object_acctid_len
    call copy_to_r14
    lea rdi, [rel txn_account_ids]
    mov rax, [rdi + rbx * 8]
    call append_uid_to_r14
    lea rsi, [rel json_txn_amount_mid]
    mov ecx, json_txn_amount_mid_len
    call copy_to_r14
    lea rdi, [rel txn_amounts]
    mov rax, [rdi + rbx * 8]
    call append_u64_to_r14
    lea rsi, [rel json_txn_type_mid]
    mov ecx, json_txn_type_mid_len
    call copy_to_r14
    lea rsi, [rel json_txn_type_deposit]
    mov ecx, json_txn_type_deposit_len
    call copy_to_r14
    lea rsi, [rel json_txn_reqid_mid]
    mov ecx, json_txn_reqid_mid_len
    call copy_to_r14
    mov rax, [rel current_req_id]
    call append_u64_to_r14
    lea rsi, [rel json_status_end]
    mov ecx, json_status_end_len
    call copy_to_r14
    lea rax, [rel json_buf]
    mov rdx, r14
    sub rdx, rax
    mov r8, rdx
    lea rdx, [rel json_buf]
    lea rsi, [rel status_200]
    mov ecx, status_200_len
    call send_json
    ret

retrieve_txn_reversal:
    lea r14, [rel json_buf]
    lea rsi, [rel json_txn_id_prefix]
    mov ecx, json_txn_id_prefix_len
    call copy_to_r14
    lea rax, [rbx + 1]
    call append_uid_to_r14
    lea rsi, [rel json_rev_txnid_mid]
    mov ecx, json_rev_txnid_mid_len
    call copy_to_r14
    lea rdi, [rel txn_link]
    mov rax, [rdi + rbx * 8]
    call append_uid_to_r14
    lea rsi, [rel json_txn_amount_mid]
    mov ecx, json_txn_amount_mid_len
    call copy_to_r14
    lea rdi, [rel txn_amounts]
    mov rax, [rdi + rbx * 8]
    call append_u64_to_r14
    lea rsi, [rel json_txn_type_mid]
    mov ecx, json_txn_type_mid_len
    call copy_to_r14
    lea rsi, [rel json_txn_type_reversal]
    mov ecx, json_txn_type_reversal_len
    call copy_to_r14
    lea rsi, [rel json_txn_reqid_mid]
    mov ecx, json_txn_reqid_mid_len
    call copy_to_r14
    mov rax, [rel current_req_id]
    call append_u64_to_r14
    lea rsi, [rel json_status_end]
    mov ecx, json_status_end_len
    call copy_to_r14
    lea rax, [rel json_buf]
    mov rdx, r14
    sub rdx, rax
    mov r8, rdx
    lea rdx, [rel json_buf]
    lea rsi, [rel status_200]
    mov ecx, status_200_len
    call send_json
    ret

respond_txn_not_found:
    lea rsi, [rel type_notfound]
    mov ecx, type_notfound_len
    lea rdx, [rel code_notfound]
    mov r8d, code_notfound_len
    lea r9, [rel msg_txn_not_found]
    mov r10d, msg_txn_not_found_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_404]
    mov ecx, status_404_len
    call send_json
    ret

# check_form_ct: RBX=request start. Returns EAX=1 ok, 0 bad.
check_form_ct:
    push rbx
    push r14
    push r15
    mov rsi, rbx
    mov rcx, [rel header_len]
    lea rdi, [rel ct_name]
    mov edx, ct_name_len
    call find_sequence_ci
    test rax, rax
    jz cfct_bad
    mov [rel hdr_tmp_first], rax
    mov rsi, rax
    inc rsi
    mov r8, rbx
    add r8, [rel header_len]
    cmp rsi, r8
    jae cfct_no_dup
    mov rcx, r8
    sub rcx, rsi
    lea rdi, [rel ct_name]
    mov edx, ct_name_len
    call find_sequence_ci
    test rax, rax
    jnz cfct_bad
cfct_no_dup:
    mov rax, [rel hdr_tmp_first]
    add rax, ct_name_len
    mov rsi, rax
    mov r8, rbx
    add r8, [rel header_len]
cfct_skip:
    cmp rsi, r8
    jae cfct_bad
    movzx eax, byte ptr [rsi]
    cmp al, 32
    je cfct_skip_inc
    cmp al, 9
    je cfct_skip_inc
    jmp cfct_val
cfct_skip_inc:
    inc rsi
    jmp cfct_skip
cfct_val:
    mov rdx, rsi
cfct_eol:
    cmp rdx, r8
    jae cfct_bad
    movzx eax, byte ptr [rdx]
    cmp al, 13
    je cfct_eol_found
    cmp al, 10
    je cfct_eol_found
    inc rdx
    jmp cfct_eol
cfct_eol_found:
    mov rcx, rdx
cfct_trim:
    cmp rcx, rsi
    jbe cfct_done
    movzx eax, byte ptr [rcx - 1]
    cmp al, 32
    je cfct_trim_dec
    cmp al, 9
    je cfct_trim_dec
    jmp cfct_done
cfct_trim_dec:
    dec rcx
    jmp cfct_trim
cfct_done:
    mov rax, rcx
    sub rax, rsi
    cmp rax, ct_expected_len
    jne cfct_bad
    mov rcx, rax
    lea rdi, [rel ct_expected]
    call buffers_equal
    test eax, eax
    jz cfct_bad
    pop r15
    pop r14
    pop rbx
    mov eax, 1
    ret
cfct_bad:
    pop r15
    pop r14
    pop rbx
    xor eax, eax
    ret

# --- Route: POST /v1/accounts/acct_<uid>/send|withdraw|deposit ---
route_post_account_money:
    lea rsi, [rbx + post_acct_prefix_len]
    mov r8, rbx
    add r8, [rel request_len]
    call extract_acct_id
    test rax, rax
    jz respond_404
    mov [rel move_src], rax
    mov r15, rsi
    mov rsi, r15
    mov rcx, r8
    sub rcx, rsi
    lea rdi, [rel send_suffix]
    mov edx, send_suffix_len
    call find_sequence
    cmp rax, r15
    je handle_send
    mov r8, rbx
    add r8, [rel request_len]
    mov rsi, r15
    mov rcx, r8
    sub rcx, rsi
    lea rdi, [rel withdraw_suffix]
    mov edx, withdraw_suffix_len
    call find_sequence
    cmp rax, r15
    je handle_withdraw
    mov r8, rbx
    add r8, [rel request_len]
    mov rsi, r15
    mov rcx, r8
    sub rcx, rsi
    lea rdi, [rel deposit_suffix]
    mov edx, deposit_suffix_len
    call find_sequence
    cmp rax, r15
    je handle_deposit
    jmp respond_404

# --- Route: POST /v1/transactions/txn_<uid>/reverse ---
route_post_txn_reverse:
    lea rsi, [rbx + post_txn_prefix_len]
    mov r8, rbx
    add r8, [rel request_len]
    call extract_txn_id
    test rax, rax
    jz respond_404
    mov [rel move_txn], rax
    mov r15, rsi
    mov rsi, r15
    mov rcx, r8
    sub rcx, rsi
    lea rdi, [rel reverse_suffix]
    mov edx, reverse_suffix_len
    call find_sequence
    cmp rax, r15
    je handle_reverse
    jmp respond_404

# --- POST /v1/accounts/acct_<uid>/send ---
handle_send:
    call check_form_ct
    test eax, eax
    jz respond_400
    mov rax, rbx
    add rax, [rel header_len]
    mov [rel body_ptr], rax
    mov rdx, rbx
    add rdx, [rel request_len]
    mov [rel body_end], rdx
    mov qword ptr [rel fv_to_seen], 0
    mov qword ptr [rel fv_amount_seen], 0
    mov qword ptr [rel fv_currency_seen], 0
    mov qword ptr [rel fv_to_num], 0
    mov qword ptr [rel fv_amount_val], 0
    mov r14, [rel body_ptr]
    mov r15, [rel body_end]
    cmp r14, r15
    je hs_missing_to
hs_token_loop:
    mov rdx, r14
hs_find_amp:
    cmp rdx, r15
    jae hs_token_end_found
    cmp byte ptr [rdx], '&'
    je hs_token_end_found
    inc rdx
    jmp hs_find_amp
hs_token_end_found:
    mov [rel form_token_end], rdx
    mov rcx, rdx
    sub rcx, r14
    test rcx, rcx
    jz hs_invalid
    mov [rel form_token_len], rcx
    mov rsi, r14
    mov rcx, [rel form_token_len]
    lea rdi, [rel to_account_id_key]
    mov edx, to_account_id_key_len
    call find_sequence
    cmp rax, r14
    je hs_parse_to
    mov rsi, r14
    mov rcx, [rel form_token_len]
    lea rdi, [rel amount_key]
    mov edx, amount_key_len
    call find_sequence
    cmp rax, r14
    je hs_parse_amount
    mov rsi, r14
    mov rcx, [rel form_token_len]
    lea rdi, [rel currency_key]
    mov edx, currency_key_len
    call find_sequence
    cmp rax, r14
    je hs_parse_currency
    jmp hs_invalid
hs_parse_to:
    cmp qword ptr [rel fv_to_seen], 0
    jne hs_invalid
    lea rsi, [r14 + to_account_id_key_len]
    mov r8, [rel form_token_end]
    mov rcx, r8
    sub rcx, rsi
    cmp rcx, acct_uid_prefix_len + UID_HEX_LEN
    jne hs_invalid
    push rsi
    push rcx
    lea rdi, [rel acct_uid_prefix]
    mov rcx, acct_uid_prefix_len
    call buffers_equal
    pop rcx
    pop rsi
    test eax, eax
    jz hs_invalid
    lea rsi, [rsi + acct_uid_prefix_len]
    lea r8, [rsi + UID_HEX_LEN]
    call decode_uid_token
    test rax, rax
    jz hs_invalid
    mov [rel fv_to_num], rax
    mov qword ptr [rel fv_to_seen], 1
    jmp hs_token_next
hs_parse_amount:
    cmp qword ptr [rel fv_amount_seen], 0
    jne hs_invalid
    lea rsi, [r14 + amount_key_len]
    mov r8, [rel form_token_end]
    xor rax, rax
    xor ecx, ecx
hs_amt_digits:
    cmp rsi, r8
    jae hs_amt_done
    movzx edx, byte ptr [rsi]
    cmp dl, '0'
    jb hs_invalid
    cmp dl, '9'
    ja hs_invalid
    inc ecx
    cmp ecx, 8
    ja hs_invalid
    imul rax, rax, 10
    sub edx, '0'
    add rax, rdx
    inc rsi
    jmp hs_amt_digits
hs_amt_done:
    test ecx, ecx
    jz hs_invalid
    test rax, rax
    jz hs_invalid
    cmp rsi, r8
    jne hs_invalid
    mov [rel fv_amount_val], rax
    mov qword ptr [rel fv_amount_seen], 1
    jmp hs_token_next
hs_parse_currency:
    cmp qword ptr [rel fv_currency_seen], 0
    jne hs_invalid
    mov rcx, [rel form_token_len]
    cmp rcx, currency_key_len + 3
    jne hs_bad_currency
    lea rsi, [r14 + currency_key_len]
    cmp byte ptr [rsi], 'u'
    jne hs_bad_currency
    cmp byte ptr [rsi + 1], 's'
    jne hs_bad_currency
    cmp byte ptr [rsi + 2], 'd'
    jne hs_bad_currency
    mov qword ptr [rel fv_currency_seen], 1
    jmp hs_token_next
hs_token_next:
    mov rsi, [rel form_token_end]
    cmp rsi, r15
    je hs_form_done
    cmp byte ptr [rsi], '&'
    jne hs_invalid
    inc rsi
    cmp rsi, r15
    jae hs_invalid
    mov r14, rsi
    jmp hs_token_loop
hs_form_done:
    cmp qword ptr [rel fv_to_seen], 1
    jne hs_missing_to
    cmp qword ptr [rel fv_amount_seen], 1
    jne hs_missing_amount
    cmp qword ptr [rel fv_currency_seen], 1
    jne hs_missing_currency

    # Money movement idempotency is scoped to this route. Check for a replay
    # before validating capacity or mutating either account.
    mov rax, [rel fv_amount_val]
    mov [rel current_amount], rax
    mov dword ptr [rel currency_tmp], 0x00647375
    mov rax, [rel move_src]
    shl rax, 32
    mov rcx, [rel fv_to_num]
    or rax, rcx
    mov [rel current_idem_context], rax
    lea rax, [rel money_send_idem_table]
    mov [rel idem_table_ptr], rax
    lea rbx, [rel request_buf]
    call parse_idempotency
    test eax, eax
    jz respond_400
    call check_idempotency
    test rax, rax
    js respond_idem_conflict
    jz hs_idem_new
    cmp rax, 1
    jb respond_txn_not_found
    cmp rax, [rel txn_count]
    ja respond_txn_not_found
    dec rax
    mov rbx, rax
    jmp retrieve_txn_transfer

hs_idem_new:
    call check_idempotency_capacity
    test eax, eax
    jz respond_table_full
    mov rax, [rel move_src]
    cmp rax, 1
    jb respond_404
    cmp rax, [rel acct_count]
    ja respond_404
    mov rax, [rel fv_to_num]
    cmp rax, 1
    jb respond_404
    cmp rax, [rel acct_count]
    ja respond_404
    mov rax, [rel move_src]
    cmp rax, [rel fv_to_num]
    je hs_self_send
    mov rax, [rel move_src]
    dec rax
    mov rbx, rax
    lea rdi, [rel acct_balances]
    mov rax, [rdi + rbx * 8]
    cmp rax, [rel fv_amount_val]
    jb hs_insufficient
    mov rax, [rel txn_count]
    cmp rax, TXN_TABLE_CAP
    jae hs_table_full
    mov rax, [rel event_count]
    cmp rax, EVENT_TABLE_CAP
    jae hs_table_full
    mov rax, [rel move_src]
    dec rax
    mov rbx, rax
    lea rdi, [rel acct_balances]
    mov rax, [rdi + rbx * 8]
    mov rcx, [rel fv_amount_val]
    sub rax, rcx
    mov [rdi + rbx * 8], rax
    mov rax, [rel fv_to_num]
    dec rax
    mov rbx, rax
    mov rax, [rdi + rbx * 8]
    add rax, rcx
    mov [rdi + rbx * 8], rax
    mov r10, [rel txn_count]
    lea rdi, [rel txn_account_ids]
    mov rax, [rel move_src]
    mov [rdi + r10 * 8], rax
    lea rdi, [rel txn_extra]
    mov rax, [rel fv_to_num]
    mov [rdi + r10 * 8], rax
    lea rdi, [rel txn_amounts]
    mov rax, [rel fv_amount_val]
    mov [rdi + r10 * 8], rax
    lea rdi, [rel txn_types]
    mov qword ptr [rdi + r10 * 8], 2
    lea rdi, [rel txn_flags]
    mov qword ptr [rdi + r10 * 8], 0
    lea rdi, [rel txn_link]
    mov qword ptr [rdi + r10 * 8], 0
    inc qword ptr [rel txn_count]
    mov r10, [rel event_count]
    lea rdi, [rel event_kinds]
    mov qword ptr [rdi + r10 * 8], 1
    lea rdi, [rel event_txn_ids]
    mov rax, [rel txn_count]
    mov [rdi + r10 * 8], rax
    lea rdi, [rel event_amounts]
    mov rax, [rel fv_amount_val]
    mov [rdi + r10 * 8], rax
    inc qword ptr [rel event_count]
    mov rax, [rel txn_count]
    mov [rel response_seq], rax
    call store_idempotency
    lea r14, [rel json_buf]
    lea rsi, [rel json_txn_id_prefix]
    mov ecx, json_txn_id_prefix_len
    call copy_to_r14
    mov rax, [rel txn_count]
    call append_uid_to_r14
    lea rsi, [rel json_transfer_sender_mid]
    mov ecx, json_transfer_sender_mid_len
    call copy_to_r14
    mov rax, [rel move_src]
    call append_uid_to_r14
    lea rsi, [rel json_transfer_recipient_mid]
    mov ecx, json_transfer_recipient_mid_len
    call copy_to_r14
    mov rax, [rel fv_to_num]
    call append_uid_to_r14
    lea rsi, [rel json_txn_amount_mid]
    mov ecx, json_txn_amount_mid_len
    call copy_to_r14
    mov rax, [rel fv_amount_val]
    call append_u64_to_r14
    lea rsi, [rel json_txn_type_mid]
    mov ecx, json_txn_type_mid_len
    call copy_to_r14
    lea rsi, [rel json_txn_type_transfer]
    mov ecx, json_txn_type_transfer_len
    call copy_to_r14
    lea rsi, [rel json_txn_reqid_mid]
    mov ecx, json_txn_reqid_mid_len
    call copy_to_r14
    mov rax, [rel current_req_id]
    call append_u64_to_r14
    lea rsi, [rel json_status_end]
    mov ecx, json_status_end_len
    call copy_to_r14
    lea rax, [rel json_buf]
    mov rdx, r14
    sub rdx, rax
    mov r8, rdx
    lea rdx, [rel json_buf]
    lea rsi, [rel status_200]
    mov ecx, status_200_len
    call send_json
    ret
hs_missing_to:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_param_error]
    mov r8d, code_param_error_len
    lea r9, [rel msg_missing_to_account]
    mov r10d, msg_missing_to_account_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_400]
    mov ecx, status_400_len
    call send_json
    ret
hs_missing_amount:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_param_error]
    mov r8d, code_param_error_len
    lea r9, [rel msg_missing_amount]
    mov r10d, msg_missing_amount_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_400]
    mov ecx, status_400_len
    call send_json
    ret
hs_missing_currency:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_param_error]
    mov r8d, code_param_error_len
    lea r9, [rel msg_missing_currency]
    mov r10d, msg_missing_currency_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_400]
    mov ecx, status_400_len
    call send_json
    ret
hs_bad_currency:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_param_error]
    mov r8d, code_param_error_len
    lea r9, [rel msg_invalid_currency]
    mov r10d, msg_invalid_currency_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_400]
    mov ecx, status_400_len
    call send_json
    ret
hs_invalid:
    jmp respond_400
hs_self_send:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_param_error]
    mov r8d, code_param_error_len
    lea r9, [rel msg_self_send]
    mov r10d, msg_self_send_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_400]
    mov ecx, status_400_len
    call send_json
    ret
hs_insufficient:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_insufficient]
    mov r8d, code_insufficient_len
    lea r9, [rel msg_insufficient]
    mov r10d, msg_insufficient_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_402]
    mov ecx, status_402_len
    call send_json
    ret
hs_table_full:
    jmp ca_table_full

# --- POST /v1/accounts/acct_<uid>/withdraw ---
handle_withdraw:
    call check_form_ct
    test eax, eax
    jz respond_400
    mov rax, rbx
    add rax, [rel header_len]
    mov [rel body_ptr], rax
    mov rdx, rbx
    add rdx, [rel request_len]
    mov [rel body_end], rdx
    mov qword ptr [rel fv_amount_seen], 0
    mov qword ptr [rel fv_currency_seen], 0
    mov qword ptr [rel fv_amount_val], 0
    mov r14, [rel body_ptr]
    mov r15, [rel body_end]
    cmp r14, r15
    je hw_missing_amount
hw_token_loop:
    mov rdx, r14
hw_find_amp:
    cmp rdx, r15
    jae hw_token_end_found
    cmp byte ptr [rdx], '&'
    je hw_token_end_found
    inc rdx
    jmp hw_find_amp
hw_token_end_found:
    mov [rel form_token_end], rdx
    mov rcx, rdx
    sub rcx, r14
    test rcx, rcx
    jz hw_invalid
    mov [rel form_token_len], rcx
    mov rsi, r14
    mov rcx, [rel form_token_len]
    lea rdi, [rel amount_key]
    mov edx, amount_key_len
    call find_sequence
    cmp rax, r14
    je hw_parse_amount
    mov rsi, r14
    mov rcx, [rel form_token_len]
    lea rdi, [rel currency_key]
    mov edx, currency_key_len
    call find_sequence
    cmp rax, r14
    je hw_parse_currency
    jmp hw_invalid
hw_parse_amount:
    cmp qword ptr [rel fv_amount_seen], 0
    jne hw_invalid
    lea rsi, [r14 + amount_key_len]
    mov r8, [rel form_token_end]
    xor rax, rax
    xor ecx, ecx
hw_amt_digits:
    cmp rsi, r8
    jae hw_amt_done
    movzx edx, byte ptr [rsi]
    cmp dl, '0'
    jb hw_invalid
    cmp dl, '9'
    ja hw_invalid
    inc ecx
    cmp ecx, 8
    ja hw_invalid
    imul rax, rax, 10
    sub edx, '0'
    add rax, rdx
    inc rsi
    jmp hw_amt_digits
hw_amt_done:
    test ecx, ecx
    jz hw_invalid
    test rax, rax
    jz hw_invalid
    cmp rsi, r8
    jne hw_invalid
    mov [rel fv_amount_val], rax
    mov qword ptr [rel fv_amount_seen], 1
    jmp hw_token_next
hw_parse_currency:
    cmp qword ptr [rel fv_currency_seen], 0
    jne hw_invalid
    mov rcx, [rel form_token_len]
    cmp rcx, currency_key_len + 3
    jne hw_bad_currency
    lea rsi, [r14 + currency_key_len]
    cmp byte ptr [rsi], 'u'
    jne hw_bad_currency
    cmp byte ptr [rsi + 1], 's'
    jne hw_bad_currency
    cmp byte ptr [rsi + 2], 'd'
    jne hw_bad_currency
    mov qword ptr [rel fv_currency_seen], 1
    jmp hw_token_next
hw_token_next:
    mov rsi, [rel form_token_end]
    cmp rsi, r15
    je hw_form_done
    cmp byte ptr [rsi], '&'
    jne hw_invalid
    inc rsi
    cmp rsi, r15
    jae hw_invalid
    mov r14, rsi
    jmp hw_token_loop
hw_form_done:
    cmp qword ptr [rel fv_amount_seen], 1
    jne hw_missing_amount
    cmp qword ptr [rel fv_currency_seen], 1
    jne hw_missing_currency

    # Money movement idempotency is scoped to this route. Check for a replay
    # before validating capacity or mutating the account.
    mov rax, [rel fv_amount_val]
    mov [rel current_amount], rax
    mov dword ptr [rel currency_tmp], 0x00647375
    mov rax, [rel move_src]
    mov [rel current_idem_context], rax
    lea rax, [rel money_withdraw_idem_table]
    mov [rel idem_table_ptr], rax
    lea rbx, [rel request_buf]
    call parse_idempotency
    test eax, eax
    jz respond_400
    call check_idempotency
    test rax, rax
    js respond_idem_conflict
    jz hw_idem_new
    cmp rax, 1
    jb respond_txn_not_found
    cmp rax, [rel txn_count]
    ja respond_txn_not_found
    dec rax
    mov rbx, rax
    jmp retrieve_txn_withdrawal

hw_idem_new:
    call check_idempotency_capacity
    test eax, eax
    jz respond_table_full
    mov rax, [rel move_src]
    cmp rax, 1
    jb respond_404
    cmp rax, [rel acct_count]
    ja respond_404
    mov rax, [rel move_src]
    dec rax
    mov rbx, rax
    lea rdi, [rel acct_balances]
    mov rax, [rdi + rbx * 8]
    cmp rax, [rel fv_amount_val]
    jb hw_insufficient
    mov rax, [rel txn_count]
    cmp rax, TXN_TABLE_CAP
    jae hw_table_full
    mov rax, [rel event_count]
    cmp rax, EVENT_TABLE_CAP
    jae hw_table_full
    mov rax, [rel move_src]
    dec rax
    mov rbx, rax
    lea rdi, [rel acct_balances]
    mov rax, [rdi + rbx * 8]
    mov rcx, [rel fv_amount_val]
    sub rax, rcx
    mov [rdi + rbx * 8], rax
    mov r10, [rel txn_count]
    lea rdi, [rel txn_account_ids]
    mov rax, [rel move_src]
    mov [rdi + r10 * 8], rax
    lea rdi, [rel txn_extra]
    mov qword ptr [rdi + r10 * 8], 0
    lea rdi, [rel txn_amounts]
    mov rax, [rel fv_amount_val]
    mov [rdi + r10 * 8], rax
    lea rdi, [rel txn_types]
    mov qword ptr [rdi + r10 * 8], 3
    lea rdi, [rel txn_flags]
    mov qword ptr [rdi + r10 * 8], 0
    lea rdi, [rel txn_link]
    mov qword ptr [rdi + r10 * 8], 0
    inc qword ptr [rel txn_count]
    mov r10, [rel event_count]
    lea rdi, [rel event_kinds]
    mov qword ptr [rdi + r10 * 8], 2
    lea rdi, [rel event_txn_ids]
    mov rax, [rel txn_count]
    mov [rdi + r10 * 8], rax
    lea rdi, [rel event_amounts]
    mov rax, [rel fv_amount_val]
    mov [rdi + r10 * 8], rax
    inc qword ptr [rel event_count]
    mov rax, [rel txn_count]
    mov [rel response_seq], rax
    call store_idempotency
    mov rax, [rel txn_count]
    dec rax
    mov rbx, rax
    lea r14, [rel json_buf]
    lea rsi, [rel json_txn_id_prefix]
    mov ecx, json_txn_id_prefix_len
    call copy_to_r14
    lea rax, [rbx + 1]
    call append_uid_to_r14
    lea rsi, [rel json_txn_object_acctid]
    mov ecx, json_txn_object_acctid_len
    call copy_to_r14
    lea rdi, [rel txn_account_ids]
    mov rax, [rdi + rbx * 8]
    call append_uid_to_r14
    lea rsi, [rel json_txn_amount_mid]
    mov ecx, json_txn_amount_mid_len
    call copy_to_r14
    lea rdi, [rel txn_amounts]
    mov rax, [rdi + rbx * 8]
    call append_u64_to_r14
    lea rsi, [rel json_txn_type_mid]
    mov ecx, json_txn_type_mid_len
    call copy_to_r14
    lea rsi, [rel json_txn_type_withdrawal]
    mov ecx, json_txn_type_withdrawal_len
    call copy_to_r14
    lea rsi, [rel json_txn_reqid_mid]
    mov ecx, json_txn_reqid_mid_len
    call copy_to_r14
    mov rax, [rel current_req_id]
    call append_u64_to_r14
    lea rsi, [rel json_status_end]
    mov ecx, json_status_end_len
    call copy_to_r14
    lea rax, [rel json_buf]
    mov rdx, r14
    sub rdx, rax
    mov r8, rdx
    lea rdx, [rel json_buf]
    lea rsi, [rel status_200]
    mov ecx, status_200_len
    call send_json
    ret
hw_missing_amount:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_param_error]
    mov r8d, code_param_error_len
    lea r9, [rel msg_missing_amount]
    mov r10d, msg_missing_amount_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_400]
    mov ecx, status_400_len
    call send_json
    ret
hw_missing_currency:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_param_error]
    mov r8d, code_param_error_len
    lea r9, [rel msg_missing_currency]
    mov r10d, msg_missing_currency_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_400]
    mov ecx, status_400_len
    call send_json
    ret
hw_bad_currency:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_param_error]
    mov r8d, code_param_error_len
    lea r9, [rel msg_invalid_currency]
    mov r10d, msg_invalid_currency_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_400]
    mov ecx, status_400_len
    call send_json
    ret
hw_invalid:
    jmp respond_400
hw_insufficient:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_insufficient]
    mov r8d, code_insufficient_len
    lea r9, [rel msg_insufficient]
    mov r10d, msg_insufficient_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_402]
    mov ecx, status_402_len
    call send_json
    ret
hw_table_full:
    jmp ca_table_full

# --- POST /v1/accounts/acct_<uid>/deposit (minimal funding for money-movement tests) ---
handle_deposit:
    call check_form_ct
    test eax, eax
    jz respond_400
    mov rax, rbx
    add rax, [rel header_len]
    mov [rel body_ptr], rax
    mov rdx, rbx
    add rdx, [rel request_len]
    mov [rel body_end], rdx
    mov qword ptr [rel fv_amount_seen], 0
    mov qword ptr [rel fv_currency_seen], 0
    mov qword ptr [rel fv_amount_val], 0
    mov r14, [rel body_ptr]
    mov r15, [rel body_end]
    cmp r14, r15
    je hd_missing_amount
hd_token_loop:
    mov rdx, r14
hd_find_amp:
    cmp rdx, r15
    jae hd_token_end_found
    cmp byte ptr [rdx], '&'
    je hd_token_end_found
    inc rdx
    jmp hd_find_amp
hd_token_end_found:
    mov [rel form_token_end], rdx
    mov rcx, rdx
    sub rcx, r14
    test rcx, rcx
    jz hd_invalid
    mov [rel form_token_len], rcx
    mov rsi, r14
    mov rcx, [rel form_token_len]
    lea rdi, [rel amount_key]
    mov edx, amount_key_len
    call find_sequence
    cmp rax, r14
    je hd_parse_amount
    mov rsi, r14
    mov rcx, [rel form_token_len]
    lea rdi, [rel currency_key]
    mov edx, currency_key_len
    call find_sequence
    cmp rax, r14
    je hd_parse_currency
    jmp hd_invalid
hd_parse_amount:
    cmp qword ptr [rel fv_amount_seen], 0
    jne hd_invalid
    lea rsi, [r14 + amount_key_len]
    mov r8, [rel form_token_end]
    xor rax, rax
    xor ecx, ecx
hd_amt_digits:
    cmp rsi, r8
    jae hd_amt_done
    movzx edx, byte ptr [rsi]
    cmp dl, '0'
    jb hd_invalid
    cmp dl, '9'
    ja hd_invalid
    inc ecx
    cmp ecx, 8
    ja hd_invalid
    imul rax, rax, 10
    sub edx, '0'
    add rax, rdx
    inc rsi
    jmp hd_amt_digits
hd_amt_done:
    test ecx, ecx
    jz hd_invalid
    test rax, rax
    jz hd_invalid
    cmp rsi, r8
    jne hd_invalid
    mov [rel fv_amount_val], rax
    mov qword ptr [rel fv_amount_seen], 1
    jmp hd_token_next
hd_parse_currency:
    cmp qword ptr [rel fv_currency_seen], 0
    jne hd_invalid
    mov rcx, [rel form_token_len]
    cmp rcx, currency_key_len + 3
    jne hd_bad_currency
    lea rsi, [r14 + currency_key_len]
    cmp byte ptr [rsi], 'u'
    jne hd_bad_currency
    cmp byte ptr [rsi + 1], 's'
    jne hd_bad_currency
    cmp byte ptr [rsi + 2], 'd'
    jne hd_bad_currency
    mov qword ptr [rel fv_currency_seen], 1
    jmp hd_token_next
hd_token_next:
    mov rsi, [rel form_token_end]
    cmp rsi, r15
    je hd_form_done
    cmp byte ptr [rsi], '&'
    jne hd_invalid
    inc rsi
    cmp rsi, r15
    jae hd_invalid
    mov r14, rsi
    jmp hd_token_loop
hd_form_done:
    cmp qword ptr [rel fv_amount_seen], 1
    jne hd_missing_amount
    cmp qword ptr [rel fv_currency_seen], 1
    jne hd_missing_currency

    # Money movement idempotency is scoped to this route. Check for a replay
    # before validating capacity or mutating the account.
    mov rax, [rel fv_amount_val]
    mov [rel current_amount], rax
    mov dword ptr [rel currency_tmp], 0x00647375
    mov rax, [rel move_src]
    mov [rel current_idem_context], rax
    lea rax, [rel money_deposit_idem_table]
    mov [rel idem_table_ptr], rax
    lea rbx, [rel request_buf]
    call parse_idempotency
    test eax, eax
    jz respond_400
    call check_idempotency
    test rax, rax
    js respond_idem_conflict
    jz hd_idem_new
    cmp rax, 1
    jb respond_txn_not_found
    cmp rax, [rel txn_count]
    ja respond_txn_not_found
    dec rax
    mov rbx, rax
    jmp retrieve_txn_deposit

hd_idem_new:
    call check_idempotency_capacity
    test eax, eax
    jz respond_table_full
    mov rax, [rel move_src]
    cmp rax, 1
    jb respond_404
    cmp rax, [rel acct_count]
    ja respond_404
    mov rax, [rel txn_count]
    cmp rax, TXN_TABLE_CAP
    jae hd_table_full
    mov rax, [rel event_count]
    cmp rax, EVENT_TABLE_CAP
    jae hd_table_full
    mov rax, [rel move_src]
    dec rax
    mov rbx, rax
    lea rdi, [rel acct_balances]
    mov rax, [rdi + rbx * 8]
    mov rcx, [rel fv_amount_val]
    add rax, rcx
    mov [rdi + rbx * 8], rax
    mov r10, [rel txn_count]
    lea rdi, [rel txn_account_ids]
    mov rax, [rel move_src]
    mov [rdi + r10 * 8], rax
    lea rdi, [rel txn_extra]
    mov qword ptr [rdi + r10 * 8], 0
    lea rdi, [rel txn_amounts]
    mov rax, [rel fv_amount_val]
    mov [rdi + r10 * 8], rax
    lea rdi, [rel txn_types]
    mov qword ptr [rdi + r10 * 8], 5
    lea rdi, [rel txn_flags]
    mov qword ptr [rdi + r10 * 8], 0
    lea rdi, [rel txn_link]
    mov qword ptr [rdi + r10 * 8], 0
    inc qword ptr [rel txn_count]
    mov r10, [rel event_count]
    lea rdi, [rel event_kinds]
    mov qword ptr [rdi + r10 * 8], 3
    lea rdi, [rel event_txn_ids]
    mov rax, [rel txn_count]
    mov [rdi + r10 * 8], rax
    lea rdi, [rel event_amounts]
    mov rax, [rel fv_amount_val]
    mov [rdi + r10 * 8], rax
    inc qword ptr [rel event_count]
    mov rax, [rel txn_count]
    mov [rel response_seq], rax
    call store_idempotency
    mov rax, [rel txn_count]
    dec rax
    mov rbx, rax
    lea r14, [rel json_buf]
    lea rsi, [rel json_txn_id_prefix]
    mov ecx, json_txn_id_prefix_len
    call copy_to_r14
    lea rax, [rbx + 1]
    call append_uid_to_r14
    lea rsi, [rel json_txn_object_acctid]
    mov ecx, json_txn_object_acctid_len
    call copy_to_r14
    lea rdi, [rel txn_account_ids]
    mov rax, [rdi + rbx * 8]
    call append_uid_to_r14
    lea rsi, [rel json_txn_amount_mid]
    mov ecx, json_txn_amount_mid_len
    call copy_to_r14
    lea rdi, [rel txn_amounts]
    mov rax, [rdi + rbx * 8]
    call append_u64_to_r14
    lea rsi, [rel json_txn_type_mid]
    mov ecx, json_txn_type_mid_len
    call copy_to_r14
    lea rsi, [rel json_txn_type_deposit]
    mov ecx, json_txn_type_deposit_len
    call copy_to_r14
    lea rsi, [rel json_txn_reqid_mid]
    mov ecx, json_txn_reqid_mid_len
    call copy_to_r14
    mov rax, [rel current_req_id]
    call append_u64_to_r14
    lea rsi, [rel json_status_end]
    mov ecx, json_status_end_len
    call copy_to_r14
    lea rax, [rel json_buf]
    mov rdx, r14
    sub rdx, rax
    mov r8, rdx
    lea rdx, [rel json_buf]
    lea rsi, [rel status_200]
    mov ecx, status_200_len
    call send_json
    ret
hd_missing_amount:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_param_error]
    mov r8d, code_param_error_len
    lea r9, [rel msg_missing_amount]
    mov r10d, msg_missing_amount_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_400]
    mov ecx, status_400_len
    call send_json
    ret
hd_missing_currency:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_param_error]
    mov r8d, code_param_error_len
    lea r9, [rel msg_missing_currency]
    mov r10d, msg_missing_currency_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_400]
    mov ecx, status_400_len
    call send_json
    ret
hd_bad_currency:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_param_error]
    mov r8d, code_param_error_len
    lea r9, [rel msg_invalid_currency]
    mov r10d, msg_invalid_currency_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_400]
    mov ecx, status_400_len
    call send_json
    ret
hd_invalid:
    jmp respond_400
hd_table_full:
    jmp ca_table_full

# --- POST /v1/transactions/txn_<uid>/reverse ---
handle_reverse:
    mov rax, [rel move_txn]
    cmp rax, 1
    jb respond_txn_not_found
    cmp rax, [rel txn_count]
    ja respond_txn_not_found
    mov rbx, rax
    dec rbx
    mov [rel move_txn], rbx
    lea rdi, [rel txn_flags]
    cmp qword ptr [rdi + rbx * 8], 0
    jne hr_already_reversed
    lea rdi, [rel txn_types]
    mov rax, [rdi + rbx * 8]
    cmp rax, 2
    je hr_do_transfer
    cmp rax, 3
    je hr_do_withdrawal
    cmp rax, 5
    je hr_do_deposit
    jmp hr_cannot_reverse
hr_do_transfer:
    lea rdi, [rel txn_amounts]
    mov rax, [rdi + rbx * 8]
    mov [rel move_amount], rax
    lea rdi, [rel txn_account_ids]
    mov rax, [rdi + rbx * 8]
    mov [rel move_src], rax
    lea rdi, [rel txn_extra]
    mov rax, [rdi + rbx * 8]
    mov [rel move_dst], rax
    mov rax, [rel move_dst]
    dec rax
    mov r10, rax
    lea rdi, [rel acct_balances]
    mov rax, [rdi + r10 * 8]
    cmp rax, [rel move_amount]
    jb hr_insufficient
    mov rax, [rel txn_count]
    cmp rax, TXN_TABLE_CAP
    jae hr_table_full
    mov rax, [rel event_count]
    cmp rax, EVENT_TABLE_CAP
    jae hr_table_full
    mov rax, [rel move_dst]
    dec rax
    mov r10, rax
    lea rdi, [rel acct_balances]
    mov rax, [rdi + r10 * 8]
    mov rcx, [rel move_amount]
    sub rax, rcx
    mov [rdi + r10 * 8], rax
    mov rax, [rel move_src]
    dec rax
    mov r10, rax
    mov rax, [rdi + r10 * 8]
    add rax, rcx
    mov [rdi + r10 * 8], rax
    jmp hr_commit
hr_do_withdrawal:
    mov rax, [rel txn_count]
    cmp rax, TXN_TABLE_CAP
    jae hr_table_full
    mov rax, [rel event_count]
    cmp rax, EVENT_TABLE_CAP
    jae hr_table_full
    lea rdi, [rel txn_amounts]
    mov rax, [rdi + rbx * 8]
    mov [rel move_amount], rax
    lea rdi, [rel txn_account_ids]
    mov rax, [rdi + rbx * 8]
    mov [rel move_src], rax
    mov qword ptr [rel move_dst], 0
    mov rax, [rel move_src]
    dec rax
    mov r10, rax
    lea rdi, [rel acct_balances]
    mov rax, [rdi + r10 * 8]
    mov rcx, [rel move_amount]
    add rax, rcx
    mov [rdi + r10 * 8], rax
    jmp hr_commit
hr_do_deposit:
    lea rdi, [rel txn_amounts]
    mov rax, [rdi + rbx * 8]
    mov [rel move_amount], rax
    lea rdi, [rel txn_account_ids]
    mov rax, [rdi + rbx * 8]
    mov [rel move_src], rax
    mov qword ptr [rel move_dst], 0
    mov rax, [rel move_src]
    dec rax
    mov r10, rax
    lea rdi, [rel acct_balances]
    mov rax, [rdi + r10 * 8]
    cmp rax, [rel move_amount]
    jb hr_insufficient
    mov rax, [rel txn_count]
    cmp rax, TXN_TABLE_CAP
    jae hr_table_full
    mov rax, [rel event_count]
    cmp rax, EVENT_TABLE_CAP
    jae hr_table_full
    mov rax, [rel move_src]
    dec rax
    mov r10, rax
    lea rdi, [rel acct_balances]
    mov rax, [rdi + r10 * 8]
    mov rcx, [rel move_amount]
    sub rax, rcx
    mov [rdi + r10 * 8], rax
    jmp hr_commit
hr_commit:
    mov rbx, [rel move_txn]
    lea rdi, [rel txn_flags]
    mov qword ptr [rdi + rbx * 8], 1
    mov r10, [rel txn_count]
    lea rdi, [rel txn_account_ids]
    mov rax, [rel move_src]
    mov [rdi + r10 * 8], rax
    lea rdi, [rel txn_extra]
    mov rax, [rel move_dst]
    mov [rdi + r10 * 8], rax
    lea rdi, [rel txn_amounts]
    mov rax, [rel move_amount]
    mov [rdi + r10 * 8], rax
    lea rdi, [rel txn_types]
    mov qword ptr [rdi + r10 * 8], 4
    lea rdi, [rel txn_flags]
    mov qword ptr [rdi + r10 * 8], 0
    lea rdi, [rel txn_link]
    mov rax, [rel move_txn]
    inc rax
    mov [rdi + r10 * 8], rax
    inc qword ptr [rel txn_count]
    mov r10, [rel event_count]
    lea rdi, [rel event_kinds]
    mov qword ptr [rdi + r10 * 8], 4
    lea rdi, [rel event_txn_ids]
    mov rax, [rel txn_count]
    mov [rdi + r10 * 8], rax
    lea rdi, [rel event_amounts]
    mov rax, [rel move_amount]
    mov [rdi + r10 * 8], rax
    inc qword ptr [rel event_count]
    mov rax, [rel txn_count]
    dec rax
    mov rbx, rax
    lea r14, [rel json_buf]
    lea rsi, [rel json_txn_id_prefix]
    mov ecx, json_txn_id_prefix_len
    call copy_to_r14
    lea rax, [rbx + 1]
    call append_uid_to_r14
    lea rsi, [rel json_rev_txnid_mid]
    mov ecx, json_rev_txnid_mid_len
    call copy_to_r14
    lea rdi, [rel txn_link]
    mov rax, [rdi + rbx * 8]
    call append_uid_to_r14
    lea rsi, [rel json_txn_amount_mid]
    mov ecx, json_txn_amount_mid_len
    call copy_to_r14
    lea rdi, [rel txn_amounts]
    mov rax, [rdi + rbx * 8]
    call append_u64_to_r14
    lea rsi, [rel json_txn_type_mid]
    mov ecx, json_txn_type_mid_len
    call copy_to_r14
    lea rsi, [rel json_txn_type_reversal]
    mov ecx, json_txn_type_reversal_len
    call copy_to_r14
    lea rsi, [rel json_txn_reqid_mid]
    mov ecx, json_txn_reqid_mid_len
    call copy_to_r14
    mov rax, [rel current_req_id]
    call append_u64_to_r14
    lea rsi, [rel json_status_end]
    mov ecx, json_status_end_len
    call copy_to_r14
    lea rax, [rel json_buf]
    mov rdx, r14
    sub rdx, rax
    mov r8, rdx
    lea rdx, [rel json_buf]
    lea rsi, [rel status_200]
    mov ecx, status_200_len
    call send_json
    ret
hr_already_reversed:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_param_error]
    mov r8d, code_param_error_len
    lea r9, [rel msg_already_reversed]
    mov r10d, msg_already_reversed_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_400]
    mov ecx, status_400_len
    call send_json
    ret
hr_cannot_reverse:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_param_error]
    mov r8d, code_param_error_len
    lea r9, [rel msg_cannot_reverse]
    mov r10d, msg_cannot_reverse_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_400]
    mov ecx, status_400_len
    call send_json
    ret
hr_insufficient:
    lea rsi, [rel type_param_error]
    mov ecx, type_param_error_len
    lea rdx, [rel code_insufficient]
    mov r8d, code_insufficient_len
    lea r9, [rel msg_insufficient]
    mov r10d, msg_insufficient_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_402]
    mov ecx, status_402_len
    call send_json
    ret
hr_table_full:
    jmp ca_table_full

# append_event_item: RBX=0-based event index, R14=json ptr. Appends item without request_id.
append_event_item:
    push rbx
    push r15
    lea rsi, [rel json_evt_id_prefix]
    mov ecx, json_evt_id_prefix_len
    call copy_to_r14
    pop r15
    push r15
    mov rax, rbx
    inc rax
    call append_uid_to_r14
    lea rsi, [rel json_evt_object_type]
    mov ecx, json_evt_object_type_len
    call copy_to_r14
    pop r15
    push r15
    lea rdi, [rel event_kinds]
    mov rax, [rdi + rbx * 8]
    cmp rax, 1
    je aei_kind_transfer
    cmp rax, 2
    je aei_kind_withdrawal
    cmp rax, 3
    je aei_kind_deposit
    lea rsi, [rel evt_kind_reversal]
    mov ecx, evt_kind_reversal_len
    call copy_to_r14
    jmp aei_after_kind
aei_kind_transfer:
    lea rsi, [rel evt_kind_transfer]
    mov ecx, evt_kind_transfer_len
    call copy_to_r14
    jmp aei_after_kind
aei_kind_withdrawal:
    lea rsi, [rel evt_kind_withdrawal]
    mov ecx, evt_kind_withdrawal_len
    call copy_to_r14
    jmp aei_after_kind
aei_kind_deposit:
    lea rsi, [rel evt_kind_deposit]
    mov ecx, evt_kind_deposit_len
    call copy_to_r14
    jmp aei_after_kind
aei_after_kind:
    lea rsi, [rel json_evt_txn_mid]
    mov ecx, json_evt_txn_mid_len
    call copy_to_r14
    pop r15
    push r15
    lea rdi, [rel event_txn_ids]
    mov rax, [rdi + rbx * 8]
    call append_uid_to_r14
    lea rsi, [rel json_evt_amount_mid]
    mov ecx, json_evt_amount_mid_len
    call copy_to_r14
    pop r15
    push r15
    lea rdi, [rel event_amounts]
    mov rax, [rdi + rbx * 8]
    call append_u64_to_r14
    lea rsi, [rel json_evt_currency_mid]
    mov ecx, json_evt_currency_mid_len
    call copy_to_r14
    pop r15
    pop rbx
    ret

# --- GET /v1/events/evt_<uid> ---
retrieve_event:
    lea rsi, [rbx + get_events_prefix_len]
    mov r8, rbx
    add r8, [rel request_len]
    call decode_uid_token
    test rax, rax
    jz respond_404
    cmp rsi, r8
    jae revt_path_ok
    cmp byte ptr [rsi], ' '
    jne respond_404
revt_path_ok:
    cmp rax, [rel event_count]
    ja revt_not_found
    mov rbx, rax
    dec rbx
    lea r14, [rel json_buf]
    call append_event_item
    lea rsi, [rel json_evt_reqid_mid]
    mov ecx, json_evt_reqid_mid_len
    call copy_to_r14
    mov rax, [rel current_req_id]
    call append_u64_to_r14
    lea rsi, [rel json_status_end]
    mov ecx, json_status_end_len
    call copy_to_r14
    lea rax, [rel json_buf]
    mov rdx, r14
    sub rdx, rax
    mov r8, rdx
    lea rdx, [rel json_buf]
    lea rsi, [rel status_200]
    mov ecx, status_200_len
    call send_json
    ret
revt_not_found:
    lea rsi, [rel type_notfound]
    mov ecx, type_notfound_len
    lea rdx, [rel code_notfound]
    mov r8d, code_notfound_len
    lea r9, [rel msg_event_not_found]
    mov r10d, msg_event_not_found_len
    call build_error_json
    mov r8, rax
    lea rdx, [rel json_buf]
    lea rsi, [rel status_404]
    mov ecx, status_404_len
    call send_json
    ret

# --- GET /v1/events (list) ---
list_events:
    lea r14, [rel json_buf]
    lea rsi, [rel json_events_list_prefix]
    mov ecx, json_events_list_prefix_len
    call copy_to_r14
    mov r15, [rel event_count]
    xor ebx, ebx
    test r15, r15
    jz list_events_done
list_events_loop:
    cmp rbx, r15
    jae list_events_done
    push r15
    call append_event_item
    pop r15
    push r15
    push rbx
    lea rsi, [rel json_rbrace]
    mov ecx, json_rbrace_len
    call copy_to_r14
    pop rbx
    pop r15
    inc rbx
    cmp rbx, r15
    jae list_events_done
    push r15
    push rbx
    lea rsi, [rel json_comma]
    mov ecx, json_comma_len
    call copy_to_r14
    pop rbx
    pop r15
    jmp list_events_loop
list_events_done:
    lea rsi, [rel json_events_list_mid]
    mov ecx, json_events_list_mid_len
    call copy_to_r14
    mov rax, [rel current_req_id]
    call append_u64_to_r14
    lea rsi, [rel json_status_end]
    mov ecx, json_status_end_len
    call copy_to_r14
    lea rax, [rel json_buf]
    mov rdx, r14
    sub rdx, rax
    mov r8, rdx
    lea rdx, [rel json_buf]
    lea rsi, [rel status_200]
    mov ecx, status_200_len
    call send_json
    ret

exit_failure:
    mov eax, 60
    mov edi, 1
    syscall
