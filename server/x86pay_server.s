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
    .ascii "GET /v1/payment_intents/pi_x86_"
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
    .ascii "{\"id\":\"pi_x86_"
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
.equ IDEM_ENTRY_SZ, 288
.equ IDEM_KEY_LEN_OFF, 256
.equ IDEM_AMOUNT_OFF, 264
.equ IDEM_CURRENCY_OFF, 272
.equ IDEM_SEQ_OFF, 280

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

.section .bss

.align 8
request_buf:
    .zero 8192
response_buf:
    .zero 8192
json_buf:
    .zero 2048
num_buf:
    .zero 32
currency_tmp:
    .zero 4
current_idem:
    .zero 256

request_len:
    .quad 0
header_len:
    .quad 0
body_ptr:
    .quad 0
body_end:
    .quad 0
current_amount:
    .quad 0
current_idem_len:
    .quad 0

idem_table:
    .zero IDEM_TABLE_CAP * IDEM_ENTRY_SZ

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

.section .text
.global _start

_start:
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

    # GET /v1/payment_intents/pi_x86_<number>
    mov rsi, rbx
    mov rcx, [rel request_len]
    lea rdi, [rel get_route]
    mov edx, get_route_len
    call find_sequence
    cmp rax, rbx
    je retrieve_intent
    jmp respond_404

create_intent:
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

    lea r11, [rel idem_table]
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
    xor rax, rax
    xor r10d, r10d

parse_id_digits:
    cmp rsi, r8
    jae retrieve_id_done
    movzx edx, byte ptr [rsi]
    cmp dl, '0'
    jb retrieve_id_done
    cmp dl, '9'
    ja retrieve_id_done
    imul rax, rax, 10
    sub edx, '0'
    add rax, rdx
    inc rsi
    inc r10
    jmp parse_id_digits

retrieve_id_done:
    test r10, r10
    jz respond_404
    cmp rsi, r8
    jae id_path_ended
    cmp byte ptr [rsi], ' '
    jne respond_404
id_path_ended:
    cmp rax, 1
    jb respond_404
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

    lea r11, [rel idem_table]
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

    lea r11, [rel idem_table]
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
    call append_u64_to_r14

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

exit_failure:
    mov eax, 60
    mov edi, 1
    syscall
