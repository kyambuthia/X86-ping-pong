#define rel rip +
.intel_syntax noprefix

.section .data

.align 8
server_addr:
    .word 2                 # AF_INET
    .word 0x9210            # port 4242 in network byte order
    .long 0x0100007f        # 127.0.0.1
    .quad 0

request_line:
    .ascii "POST /v1/payment_intents HTTP/1.1\r\nHost: 127.0.0.1\r\n"
request_line_end:
.equ request_line_len, request_line_end - request_line

auth_line:
    .ascii "Authorization: Bearer x86_test_key\r\n"
auth_line_end:
.equ auth_line_len, auth_line_end - auth_line

idem_line:
    .ascii "Idempotency-Key: demo-1\r\n"
idem_line_end:
.equ idem_line_len, idem_line_end - idem_line

content_type_line:
    .ascii "Content-Type: application/x-www-form-urlencoded\r\nContent-Length: "
content_type_line_end:
.equ content_type_line_len, content_type_line_end - content_type_line

request_suffix:
    .ascii "\r\nConnection: close\r\n\r\n"
request_suffix_end:
.equ request_suffix_len, request_suffix_end - request_suffix

body_amount_key:
    .ascii "amount="
body_amount_key_end:
.equ body_amount_key_len, body_amount_key_end - body_amount_key

body_currency_key:
    .ascii "&currency="
body_currency_key_end:
.equ body_currency_key_len, body_currency_key_end - body_currency_key

default_amount:
    .ascii "2000"
default_amount_end:
.equ default_amount_len, default_amount_end - default_amount

default_currency:
    .ascii "usd"
default_currency_end:
.equ default_currency_len, default_currency_end - default_currency

.section .bss

.align 8
body_buf:
    .zero 512
request_buf:
    .zero 2048
response_buf:
    .zero 8192
num_buf:
    .zero 32
body_len:
    .quad 0

.section .text
.global _start

_start:
    mov r15, [rsp]          # argc

    # Build amount=<argv[1] or 2000>&currency=<argv[2] or usd>.
    lea r14, [rel body_buf]
    lea rsi, [rel body_amount_key]
    mov ecx, body_amount_key_len
    call copy_to_r14
    cmp r15, 2
    jb use_default_amount
    mov rsi, [rsp + 16]
    call copy_cstr_to_r14
    jmp append_currency_key

use_default_amount:
    lea rsi, [rel default_amount]
    mov ecx, default_amount_len
    call copy_to_r14

append_currency_key:
    lea rsi, [rel body_currency_key]
    mov ecx, body_currency_key_len
    call copy_to_r14
    cmp r15, 3
    jb use_default_currency
    mov rsi, [rsp + 24]
    call copy_cstr_to_r14
    jmp body_ready

use_default_currency:
    lea rsi, [rel default_currency]
    mov ecx, default_currency_len
    call copy_to_r14

body_ready:
    lea rax, [rel body_buf]
    mov rdx, r14
    sub rdx, rax
    mov [rel body_len], rdx

    # Build the HTTP request.
    lea r14, [rel request_buf]
    lea rsi, [rel request_line]
    mov ecx, request_line_len
    call copy_to_r14
    lea rsi, [rel auth_line]
    mov ecx, auth_line_len
    call copy_to_r14
    lea rsi, [rel idem_line]
    mov ecx, idem_line_len
    call copy_to_r14
    lea rsi, [rel content_type_line]
    mov ecx, content_type_line_len
    call copy_to_r14
    mov rax, [rel body_len]
    call append_u64_to_r14
    lea rsi, [rel request_suffix]
    mov ecx, request_suffix_len
    call copy_to_r14
    lea rsi, [rel body_buf]
    mov rcx, [rel body_len]
    call copy_to_r14

    # socket(AF_INET, SOCK_STREAM, 0)
    mov eax, 41
    mov edi, 2
    mov esi, 1
    xor edx, edx
    syscall
    test rax, rax
    js exit_failure
    mov r12, rax

    # connect(socket, 127.0.0.1:4242, 16)
    mov eax, 42
    mov rdi, r12
    lea rsi, [rel server_addr]
    mov edx, 16
    syscall
    test rax, rax
    js close_and_fail

    lea rsi, [rel request_buf]
    lea rax, [rel request_buf]
    mov rdx, r14
    sub rdx, rax
    mov rdi, r12
    call write_all

read_response:
    mov eax, 0
    mov rdi, r12
    lea rsi, [rel response_buf]
    mov edx, 8192
    syscall
    test rax, rax
    jle close_success
    mov rdx, rax
    mov edi, 1
    lea rsi, [rel response_buf]
    call write_all
    jmp read_response

close_success:
    mov eax, 3
    mov rdi, r12
    syscall
    mov eax, 60
    xor edi, edi
    syscall

close_and_fail:
    mov eax, 3
    mov rdi, r12
    syscall

exit_failure:
    mov eax, 60
    mov edi, 1
    syscall

copy_to_r14:
    mov rdi, r14
    rep movsb
    mov r14, rdi
    ret

copy_cstr_to_r14:
    mov rdi, r14
copy_cstr_loop:
    mov al, byte ptr [rsi]
    test al, al
    jz copy_cstr_done
    mov byte ptr [rdi], al
    inc rsi
    inc rdi
    jmp copy_cstr_loop
copy_cstr_done:
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
