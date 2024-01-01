section .data
MAX_FIBO         dq 1304969544928657
MAX_FIBO_TERMS   equ 74
LOCAL_VAR_SPACE  equ 48

FIVE             dq 5.0
TWO              dq 2.0
INIT             dq -1.0

FB_OK       equ 0
FB_TMT      equ 1
FB_TB       equ 2
FB_PRM_ERR  equ 3

abs_mask dq 7FFFFFFFFFFFFFFFh

section .bss
GOLDEN_CONST     dq ?

section .text

global fibonacci_interop_nasm

isPrime:
    push r8
    push r9
    mov r8, [rbp - 32]

    cmp r12, r8
    jg search
    mov r8, r12

search:
    mov rbx, 2
    mov r9,1

brutPrime:
    xor rdx,rdx
    mov rax, r12
    div rbx
    test rdx, rdx
    jz found
    inc rbx
    cmp rbx, r8
    jl brutPrime

    jmp exit

found:
    mov r9, 0

exit:
    mov rax, r9
    pop r9
    pop r8
    ret

factorization:
    push r10
    push rcx
    mov r11, [rbp - 32]
    mov r10, [rbp - 48]
    mov r9, [rbp + 16]

    mov r8, 0
    mov rbx, 2
    mov rcx, [r10 + 8 * r13]

start_while:
    mov rax, rcx
    xor rdx,rdx
    div rbx
    test rdx, rdx
    jnz not_a_factor

    inc r8
    mov rcx, rax
    xor r14, r14
    mov r14, r13
    add r14, r8
    mov [r10 + 8 * r14], rbx

    mov r12, rbx
    call isPrime

    test rax, rax
    jz not_prime_facto

    mov dl, 1
    mov [r9 + r14], dl

not_prime_facto:
    cmp r8, 49
    je end_factorization

not_a_factor:
    inc rbx
    cmp rbx, r11
    jg end_factorization

    cmp rcx, 1
    je end_factorization

    jmp start_while

end_factorization:
    pop rcx
    pop r10
    ret
    
fiboWork:
    mov r10 , [rbp - 16]
    mov rcx, 100
    imul r10, r10, 50
calculate_fibo:
    mov rax, [rbp - 48]
    mov rdx, 0
    mov r8, [rax + 8 * rcx - 800]
    add rdx, r8
    mov r8, [rax + 8 * rcx - 400]
    add rdx, r8
    cmp rdx, [rbp - 24]
    jg out_max_fibo
    mov [rax + 8 * rcx], rdx
    mov r12, rdx
    call isPrime

    mov r11, [rbp+16]
    test rax, rax
    jz not_prime

    mov dl, 1
    mov [r11 + rcx], dl

not_prime:
    mov r13, rcx
    call factorization
    add rcx,50
    cmp rcx, r10
    jl calculate_fibo

out_max_fibo:
    ret
    
clearAndFill:
    mov r10 , [rbp - 16]
    imul r8, r10, 50
    mov rcx, 0
    mov r9 , [rbp - 8]

loop_unsigned:
    mov rax, [rbp - 48]
    mov rdx,0
    mov [rax + 8 * rcx], rdx

    mov rax, [rbp+16]
    mov dl, 0
    mov [rax + rcx], dl
    inc rcx
    cmp rcx, r8
    jl loop_unsigned

    mov rcx, 0
    mov rax, [rbp - 48]
    mov [rax], r9
    mov [rax + 8 * 50], r9
    mov r13, 0
    call factorization
    mov r13, 50
    call factorization

loop_double:
    mov rax, [rbp+24] 
    movsd xmm0, QWORD [rel INIT]
    movsd QWORD [rax + 8 * rcx], xmm0
    inc rcx
    cmp rcx, r10
    jl loop_double
    ret

calculate_error:
    mov r10, [rbp - 16]
    mov r8, [rbp+24] 
    mov r9, [rbp - 48]
    xor r11, r11

loop_error:
    imul r12, r11, 50
    cmp r11,2
    jl two_first_value

    mov rax,[r9 + 8 * r12 - 400]
    mov rbx,[r9 + 8 * r12 - 800]
    cvtsi2sd xmm0, rax
    cvtsi2sd xmm1, rbx
    divsd xmm0, xmm1
    movsd xmm1, [rel GOLDEN_CONST]
    subsd xmm0, xmm1
    movsd xmm1, [rel abs_mask]
    andpd xmm0, xmm1
    movsd QWORD [r8 + 8 * r11], xmm0

two_first_value:
    inc r11
    cmp r11, r10
    jl loop_error
    ret
    
fibonacci_interop_nasm:
    push rbp
    mov rbp, rsp
    sub rsp, LOCAL_VAR_SPACE

    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15

    fld1
    fld QWORD [rel FIVE]  ; PTR is not used in NASM
    fsqrt
    fadd
    fld QWORD [rel TWO]   ; PTR is not used in NASM
    fdiv
    fstp QWORD [rel GOLDEN_CONST]

    
    ; Arguments in register store in local
    ; RDI -> fbStart (8 bytes)
    ; RSI -> maxTerms (1 byte)
    ; RDX -> maxFibo (8 bytes)
    ; RCX -> maxFactor (8 bytes)
    ; R8 -> nbrOfLoops - (8 bytes)
    ; R9 -> pointer to arTerms (unsigned long long*) - (8 bytes)


    mov [rbp - 8], RDI ; fbStart
    mov [rbp - 16], RSI ; maxTerms
    mov [rbp - 24], RDX ; maxFibo
    mov [rbp - 32], RCX ; maxFactor
    mov [rbp - 40], R8 ; nbrOfLoops
    mov [rbp - 48], R9 ; pointer to arTerms (unsigned long long*) 

    ; Arguments in the stack
    ; - 48 bytes of local variables 
    ; Return Address -> 0 bytes to 8 bytes (+8bytes for alignment)
    ; [rbp+16] -> pointer to arPrimes (bool*) 
    ; [rbp+24] -> pointer to arError (double*)
    ; [rbp+32] -> reference to goldenNbr

    mov rax, rcx
    mov rcx, rdx
    mov rbx, r8
    mov rdx, r9
    xor rsi, rsi
    movzx rsi, byte [rbp - 40]

    cmp rax, 1
    jl prm_err_label
    cmp rbx, 1
    jl prm_err_label
    cmp rcx, 3
    jl prm_err_label
    cmp rdx, 2
    jl prm_err_label
    cmp rsi, 1
    jl prm_err_label
    cmp rcx, 74
    jg tmt_label
    mov rax, 1304969544928657
    cmp rbx, rax
    jg too_big_label

    xor rcx,rcx

main_loop:
    call clearAndFill
    call fiboWork
    call calculate_error
    inc rcx
    cmp rcx, rsi
    jl main_loop

    mov rdx, [rbp+32]
    movsd xmm0, QWORD [rel GOLDEN_CONST]
    movsd QWORD [rdx], xmm0
    xor rax,rax
no_error:
    mov rax,  FB_OK
    jmp epilogue

too_big_label:
    mov rax, FB_TB
    jmp epilogue

tmt_label:
    mov rax, FB_TMT
    jmp epilogue

prm_err_label:
    mov rax, FB_PRM_ERR
    jmp epilogue

epilogue:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

end:
section .note.GNU-stack noalloc noexec nowrite progbits
