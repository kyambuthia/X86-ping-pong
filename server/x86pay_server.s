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

auth_header:
    .ascii "Authorization: Bearer x86_test_key"
auth_header_end:
.equ auth_header_len, auth_header_end - auth_header

idem_header:
    .ascii "Idempotency-Key: "
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

body_idem_conflict:
    .ascii "{\"error\":{\"message\":\"idempotency key reused with different parameters\"}}"
body_idem_conflict_end:
.equ body_idem_conflict_len, body_idem_conflict_end - body_idem_conflict

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
stored_idem:
    .zero 256

request_len:
    .quad 0
body_ptr:
    .quad 0
body_end:
    .quad 0
current_amount:
    .quad 0
current_idem_len:
    .quad 0
stored_idem_len:
    .quad 0
stored_idem_seq:
    .quad 0
stored_idem_amount:
    .quad 0
stored_idem_currency:
    .long 0

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

.section .text
.global _start

_start:
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
    test rax, rax
    js exit_failure
    mov r13, rax

    # This first slice intentionally handles one complete request per
    # connection. The bundled client sends the request in one write.
    mov eax, 0
    mov rdi, r13
    lea rsi, [rel request_buf]
    mov edx, 8192
    syscall
    test rax, rax
    jle close_client
    mov [rel request_len], rax
    call handle_request

close_client:
    mov eax, 3
    mov rdi, r13
    syscall
    jmp accept_loop

handle_request:
    lea rbx, [rel request_buf]

    # Every endpoint requires the local test key.
    mov rsi, rbx
    mov rcx, [rel request_len]
    lea rdi, [rel auth_header]
    mov edx, auth_header_len
    call find_sequence
    test rax, rax
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
    # Locate the form body.
    mov rsi, rbx
    mov rcx, [rel request_len]
    lea rdi, [rel header_end_marker]
    mov edx, header_end_marker_len
    call find_sequence
    test rax, rax
    jz respond_400
    add rax, header_end_marker_len
    mov [rel body_ptr], rax
    mov rdx, rbx
    add rdx, [rel request_len]
    mov [rel body_end], rdx

    # Parse amount and currency from the application/x-www-form-urlencoded body.
    call parse_amount
    test eax, eax
    jz respond_400
    call parse_currency
    test eax, eax
    jz respond_400

    call parse_idempotency
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

    lea rdi, [rel intent_amounts]
    mov rax, [rel current_amount]
    mov [rdi + rbx * 8], rax

    lea rdi, [rel intent_currencies]
    mov eax, [rel currency_tmp]
    mov [rdi + rbx * 4], eax

    inc qword ptr [rel intent_count]
    lea rax, [rbx + 1]
    mov [rel stored_idem_seq], rax

    # Retain the last idempotency key for replay in this in-memory MVP.
    mov rcx, [rel current_idem_len]
    mov [rel stored_idem_len], rcx
    test rcx, rcx
    jz no_idem_to_store
    lea rsi, [rel current_idem]
    lea rdi, [rel stored_idem]
    rep movsb
    mov rax, [rel current_amount]
    mov [rel stored_idem_amount], rax
    mov eax, [rel currency_tmp]
    mov [rel stored_idem_currency], eax

no_idem_to_store:
    mov rax, [rel stored_idem_seq]
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

# parse_amount: returns EAX=1 on success, EAX=0 on failure.
parse_amount:
    mov rsi, [rel body_ptr]
    mov rcx, [rel body_end]
    sub rcx, rsi
    lea rdi, [rel amount_key]
    mov edx, amount_key_len
    call find_sequence
    test rax, rax
    jz parse_amount_bad
    add rax, amount_key_len
    mov r8, [rel body_end]
    xor rdx, rdx
    xor r10d, r10d

parse_amount_digits:
    cmp rax, r8
    jae parse_amount_done
    movzx r9d, byte ptr [rax]
    cmp r9b, '0'
    jb parse_amount_done
    cmp r9b, '9'
    ja parse_amount_done
    imul rdx, rdx, 10
    sub r9d, '0'
    add rdx, r9
    inc rax
    inc r10
    jmp parse_amount_digits

parse_amount_done:
    test r10, r10
    jz parse_amount_bad
    test rdx, rdx
    jz parse_amount_bad
    mov [rel current_amount], rdx
    mov eax, 1
    ret

parse_amount_bad:
    xor eax, eax
    ret

# parse_currency: returns EAX=1 on success, EAX=0 on failure.
parse_currency:
    mov rsi, [rel body_ptr]
    mov rcx, [rel body_end]
    sub rcx, rsi
    lea rdi, [rel currency_key]
    mov edx, currency_key_len
    call find_sequence
    test rax, rax
    jz parse_currency_bad
    add rax, currency_key_len
    mov r8, [rel body_end]
    mov r9, rax
    add r9, 3
    cmp r9, r8
    ja parse_currency_bad

    movzx edx, byte ptr [rax]
    movzx ecx, byte ptr [rax + 1]
    movzx r8d, byte ptr [rax + 2]
    cmp dl, 'a'
    jb parse_currency_bad
    cmp dl, 'z'
    ja parse_currency_bad
    cmp cl, 'a'
    jb parse_currency_bad
    cmp cl, 'z'
    ja parse_currency_bad
    cmp r8b, 'a'
    jb parse_currency_bad
    cmp r8b, 'z'
    ja parse_currency_bad

    mov byte ptr [rel currency_tmp], dl
    mov byte ptr [rel currency_tmp + 1], cl
    mov byte ptr [rel currency_tmp + 2], r8b
    mov byte ptr [rel currency_tmp + 3], 0
    mov eax, 1
    ret

parse_currency_bad:
    xor eax, eax
    ret

# parse_idempotency: copies the latest Idempotency-Key header into current_idem.
parse_idempotency:
    mov qword ptr [rel current_idem_len], 0
    mov rsi, rbx
    mov rcx, [rel request_len]
    lea rdi, [rel idem_header]
    mov edx, idem_header_len
    call find_sequence
    test rax, rax
    jz parse_idempotency_done
    add rax, idem_header_len
    mov rsi, rax
    lea rdi, [rel current_idem]
    xor rcx, rcx

copy_idempotency:
    cmp rcx, 255
    jae idempotency_copied
    cmp rsi, [rel body_ptr]
    jb copy_idempotency_byte
    # Headers end before the body; this comparison also bounds malformed input.
copy_idempotency_byte:
    cmp rsi, rbx
    jb idempotency_copied
    mov r8, rbx
    add r8, [rel request_len]
    cmp rsi, r8
    jae idempotency_copied
    mov al, byte ptr [rsi]
    cmp al, 13
    je idempotency_copied
    cmp al, 10
    je idempotency_copied
    mov byte ptr [rdi], al
    inc rsi
    inc rdi
    inc rcx
    jmp copy_idempotency

idempotency_copied:
    mov [rel current_idem_len], rcx
parse_idempotency_done:
    ret

# check_idempotency: EAX=0 new, EAX=-1 conflict, EAX=stored sequence replay.
check_idempotency:
    mov rcx, [rel current_idem_len]
    test rcx, rcx
    jz no_matching_idempotency
    cmp rcx, [rel stored_idem_len]
    jne no_matching_idempotency
    lea rsi, [rel current_idem]
    lea rdi, [rel stored_idem]
    call buffers_equal
    test eax, eax
    jz no_matching_idempotency

    mov rax, [rel current_amount]
    cmp rax, [rel stored_idem_amount]
    jne idempotency_conflict
    mov eax, [rel currency_tmp]
    cmp eax, [rel stored_idem_currency]
    jne idempotency_conflict
    mov rax, [rel stored_idem_seq]
    ret

idempotency_conflict:
    mov rax, -1
    ret

no_matching_idempotency:
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

    lea rsi, [rel json_status_suffix]
    mov ecx, json_status_suffix_len
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

respond_400:
    lea rsi, [rel status_400]
    mov ecx, status_400_len
    lea rdx, [rel body_400]
    mov r8d, body_400_len
    call send_json
    ret

respond_idem_conflict:
    lea rsi, [rel status_400]
    mov ecx, status_400_len
    lea rdx, [rel body_idem_conflict]
    mov r8d, body_idem_conflict_len
    call send_json
    ret

respond_401:
    lea rsi, [rel status_401]
    mov ecx, status_401_len
    lea rdx, [rel body_401]
    mov r8d, body_401_len
    call send_json
    ret

respond_404:
    lea rsi, [rel status_404]
    mov ecx, status_404_len
    lea rdx, [rel body_404]
    mov r8d, body_404_len
    call send_json
    ret

write_all:
    test rdx, rdx
    jz write_all_done
write_all_loop:
    mov eax, 1
    syscall
    test rax, rax
    js write_all_done
    test rax, rax
    jz write_all_done
    sub rdx, rax
    add rsi, rax
    jnz write_all_loop
write_all_done:
    ret

exit_failure:
    mov eax, 60
    mov edi, 1
    syscall
