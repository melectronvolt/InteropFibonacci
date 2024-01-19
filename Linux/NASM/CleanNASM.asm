; -----------------------------------------------------------------------
; Author: Rémi MEVAERE
; Copyright: Copyright (c) 2024 Rémi MEVAERE
; License: MIT License
; Version: 1.0.0
; Maintainer: Rémi MEVAERE
; Email: github@volt.melectron.fr
; Website: spnet.fr
; Status: Development
; Date: 2024-01-01
; -----------------------------------------------------------------------

section .data
MAX_FIBO         dq 18446744073709551615 ; 64-bit integer constant (double qword)
MAX_FIBO_TERMS   equ 93 ; Simple Constant
LOCAL_VAR_SPACE  equ 48 ; Local variable space in bytes

; Calculate GOLDEN_CONST
FIVE             dq 5.0
TWO              dq 2.0
INIT             dq -1.0

; Enumeration for return
FB_OK       equ 0
FB_TMT      equ 1
FB_TB       equ 2
FB_PRM_ERR  equ 3

; Absolute value
abs_mask dq 7FFFFFFFFFFFFFFFh

section .bss
GOLDEN_CONST     dq ? ; Double-precision floating-point constant

section .text

; declare the function exported in the SO
; don't need _DllMainCRTStartup
global fibonacci_interop_nasm


; test if a r12 is prime number
isPrime:
    ; save on the stack r8, r9
    push r8
    push r9

    mov r8, [rbp - 32]  ;  ; r8 = maxFactor

    ; handle the maxValue 
    cmp r12, r8 ;  If numberPrime is greater than or equal to maxFactor
    jg search ; jump now to search

    ; r8 = r12
    mov r8, r12

search:
    mov rbx, 2 ; rbx = 2
    mov r9, 1 ; r9 = 1 (it's not prime)

; brutforce search
brutPrime:
    xor rdx,rdx ; rdx = 0
    mov rax, r12 ; rax = r12
    div rbx ; rax / rbx

    test rdx, rdx ; if modulo = 0, not a prime !
    jz found ; jump to end 

    ; Increment the loop counter
    inc rbx

    ; Compare the loop counter with the endpoint
    cmp rbx, r8

    ; Continue looping if rcx is less than rdx
    jl brutPrime

    jmp exit ; leave

found:
    mov r9, 0

exit:
    mov rax, r9
    ; restore r9 r8
    pop r9
    pop r8

    ret

factorization:
    ; save r10 and rcx to the stack
    push r10
    push rcx

    ; baseIndex is in r13 by the caller

    mov r11, [rbp - 32] ; r11 = maxFactor
    mov r10, [rbp - 48] ; r10 = get the first value of arTerms
    mov r9, [rbp + 16] ; r9 = get the first value of arPrimes

    mov r8, 0 ; position = 0
    mov rbx, 2 ; rbx = 2 (the start)
    mov rcx, [r10 + 8 * r13] ; rcx = result

start_while:
    mov rax, rcx ; rax = value
    xor rdx, rdx ; rdx = 0
    div rbx ; rax / rbx, modulo in rdx

    test rdx, rdx ; if rdx not 0
    jnz not_a_factor ; jump

    ; we have a number that is a factor
    inc r8 ;  r8 increase 1
    mov rcx, rax ; result of the division in rcx
    xor r14, r14 ; r14 = 0
    mov r14, r13 ; store r13 in r14 (not useful ?)
    add r14, r8 ; r14 = r14 + r8
    mov [r10 + 8 * r14], rbx ; store the factor


    ; test if prime for r12
    mov r12, rbx
    call isPrime

    ; if rax = 1 prime else rax = 0
    test rax, rax
    jz not_prime_facto

    ; here it is prime we need to modify the value
    mov dl, 1 ; True
    mov [r9 + r14], dl

not_prime_facto:
    ; end of the array jump and leave
    cmp r8, 49 ; 50 = fibo term + 49 * (factors)
    je end_factorization

not_a_factor:
    ; not a factor just increase rbx
    inc rbx

    ; if rbx too big end factorization
    cmp rbx, r11
    jg end_factorization

    ; if rcx too big end factorization
    cmp rcx, 1
    je end_factorization

    ; Continue the factorization
    jmp start_while

end_factorization:
    pop rcx
    pop r10
    ret
    
fiboWork:
    mov r10 , [rbp - 16] ; r10 = maxterms
    mov rcx, 100
    imul r10, r10, 50 ; r10 *= 50

calculate_fibo:
    mov rax, [rbp - 48] ; ptr to arTerms

    mov rdx, 0 ; rdx = 0
    mov r8, [rax + 8 * rcx - 800] ; last last term
    add rdx, r8 ; rdx = r8
    mov r8, [rax + 8 * rcx - 400] ; last term
    add rdx, r8 ; rdx = r8 + r8

    cmp rdx, [rbp - 24] ; compare to max_fibo
    jg out_max_fibo ; jump and leave

    mov [rax + 8 * rcx], rdx ; store result

    mov r12, rdx
    call isPrime ; isPrime(r12) ?
    ; return if rax = 1 prime else rax = 0

    mov r11, [rbp+16] ; pointer to arPrimes
    test rax, rax ; if rax = 0
    jz not_prime ; jump to not_prime

    ; here it is prime we need to modify the value
    mov dl, 1 ; True
    mov [r11 + rcx], dl

not_prime:
    mov r13, rcx
    call factorization ; factorization(r13)

    ; Increment the loop counter
    add rcx,50
    ; Compare the loop counter with the endpoint
    cmp rcx, r10
    ; Continue looping if rcx is less than rdx
    jl calculate_fibo

out_max_fibo:
    ret
    
clearAndFill:
    ; Clear arTerms and arPrimes
    ; --------------------------
    mov r10 , [rbp - 16] ; r10 = maxterms 
    imul r8, r10, 50 ; endpoint of the loop
    mov rcx, 0 ; counter to 0
    mov r9 , [rbp - 8] ; r9 = fbstart 

loop_unsigned:
    mov rax, [rbp - 48] ; rax = ptr to arTerms
    
    mov rdx, 0 ; rdx zero
    mov [rax + 8 * rcx], rdx ; fill with zero

    mov rax, [rbp+16] rax ; ptr to arPrimes (bool)
    mov dl, 0 ; dl to false (0)
    mov [rax + rcx], dl ; fill with zero

    ; Increment the loop counter
    inc rcx
    ; Compare the loop counter with the endpoint
    cmp rcx, r8
    ; Continue looping if rcx is less than rdx
    jl loop_unsigned

    ; First term
    ; -------------
    mov rcx, 0
    ; init the first value with r11 (fbStart)
    mov rax, [rbp - 48] ; rax = ptr to arTerms
    mov [rax], r9 ; r9 = fbstart , first term
    mov [rax + 8 * 50], r9 ; second term = fbstart

    ; Factorization of the two first terms
    mov r13, 0
    call factorization ; r13 = first value
    mov r13, 50
    call factorization ; r13 = second value

    ; Clear arError
    ; -------------
loop_double:
    mov rax, [rbp+24] ; ptr to arError
    movsd xmm0, QWORD [rel INIT] ; Load the double value -1 into xmm0

    movsd QWORD [rax + 8 * rcx], xmm0 ; fill arError with 0 (rcx =0)

    ; Increment the loop counter
    inc rcx
    ; Compare the loop counter with the endpoint
    cmp rcx, r10
    ; Continue looping if rcx is less than rdx
    jl loop_double

    ret

calculate_error:  ; Calculate and fill error array
    mov r10, [rbp - 16] ; maxterms
    mov r8, [rbp+24] ; error array
    mov r9, [rbp - 48] ; arTerms array
    xor r11, r11  ; r11 = 0 (will store the position)

loop_error:
    imul r12, r11, 50 ; r12 - position in arterms
    cmp r11, 2 ; if it's the two_first_value
    jl two_first_value ; jump

    mov rax,[r9 + 8 * r12 - 400] ; rax = last term
    mov rbx,[r9 + 8 * r12 - 800] ; rbx = last last term

    cvtsi2sd xmm0, rax ; xmm0 = rax
    cvtsi2sd xmm1, rbx ; xmm1 = rbx

    divsd xmm0, xmm1 ; xmm0 = xmm1 / xmm0

    ; Load GOLDEN_CONST into xmm1
    movsd xmm1, [rel GOLDEN_CONST]
    ; Subtract GOLDEN_CONST from xmm0
    subsd xmm0, xmm1

    ; absolute value
    movsd xmm1, [rel abs_mask] ; Load the mask into xmm1
    andpd xmm0, xmm1 ; Perform bitwise AND to clear the sign bit
    movsd QWORD [r8 + 8 * r11], xmm0 ; store error

two_first_value:
    ; Increment the loop counter
    inc r11
    ; Compare the loop counter with the endpoint
    cmp r11, r10
    ; Continue looping if rcx is less than rdx
    jl loop_error

    ret
    
fibonacci_interop_nasm:
    ; Prologue
    push rbp
    mov rbp, rsp

    ; Adjust to store the local variables
    sub rsp, LOCAL_VAR_SPACE

    ; Save non-volatile registers
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15

    ; Calculate the golden ratio: (1.0 + sqrt(5.0)) / 2.0
    fld1 ; Load 1.0 onto the FPU stack
    fld QWORD [rel FIVE]  ; Load 5.0 onto the FPU stack
    fsqrt ; Compute sqrt(5.0)
    fadd ; Add 1.0 (result: 1.0 + sqrt(5.0))
    fld QWORD [rel TWO] ; Load 2.0 onto the FPU stack
    fdiv ; Divide (1.0 + sqrt(5.0)) / 2.0
    fstp QWORD [rel GOLDEN_CONST] ; Store the result in GOLDEN_CONST

    
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
    ; Return Address -> 0 bytes to 8 bytes (+8 bytes for alignment)
    ; [rbp+16] -> pointer to arPrimes (bool*) 
    ; [rbp+24] -> pointer to arError (double*)
    ; [rbp+32] -> reference to goldenNbr


    ; Some verification
    ; -----------------
    ; Load the values of fbStart, maxFibo, maxTerms, maxFactor, and nbrOfLoops into registers
    mov rax, [rbp - 8]  ; Load fbStart into rax
    mov rcx, [rbp - 16] ; Load maxTerms into rcx
    mov rbx, [rbp - 24] ; Load maxFibo into rbx
    mov rdx, [rbp - 32] ; Load maxFactor into rdx
    xor rsi, rsi    ; Zero out rsi
    movzx rsi, byte [rbp - 40] ; ; Move 1 byte from [rbp+48] and zero-extend to 64-bit

    ; Check conditions and return PRM_ERR if any condition is true
    cmp rax, 1 ; Compare fbStart with 1
    jl prm_err_label  ; Jump to prm_err_label if fbStart < 1

    cmp rbx, 1 ; Compare maxFibo with 1
    jl prm_err_label ; Jump to prm_err_label if maxFibo < 1

    cmp rcx, 3 ; Compare maxTerms with 3
    jl prm_err_label ; Jump to prm_err_label if maxTerms < 3

    cmp rdx, 2 ; Compare maxFactor with 2
    jl prm_err_label ; Jump to prm_err_label if maxFactor < 2

    cmp rsi, 1 ; Compare nbrOfLoops with 1
    jl prm_err_label ; Jump to prm_err_label if loop < 1

    cmp rcx, MAX_FIBO_TERMS  ; Compare maxTerms with MAX_FIBO_TERMS
    jg tmt_label ; jump and leave

    mov rax, MAX_FIBO ; Same with MAX_FIBO

    cmp rbx, rax ; Compare maxFibo with MAX_FIBO
    jg too_big_label ; jump and leave

    cmp rdx, rax ; Compare maxFactor with MAX_FIBO
    jg too_big_label ; jump and leave

    xor rcx,rcx ; reset rcx to 0
main_loop:
    call clearAndFill
    call fiboWork
    call calculate_error
    ; Increment the loop counter
    inc rcx
    ; Compare the loop counter with the endpoint
    cmp rcx, rsi
    jl main_loop

    mov rdx, [rbp+32] ; reference to goldenNbr
    movsd xmm0, QWORD [rel GOLDEN_CONST]

    movsd QWORD [rdx], xmm0 ; store to goldenNbr the GOLDEN_CONST

; RETURN OF THE FUNCTION
    xor rax, rax ; rax = 0
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
    ; Restore non-volatile registers
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx

    ; Restore original rsp
    mov rsp, rbp
    pop rbp

    ; Return value in rax
    ret

end:
; boilerplate to avoid warnings
section .note.GNU-stack noalloc noexec nowrite progbits
