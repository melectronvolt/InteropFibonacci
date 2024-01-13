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

.data
MAX_FIBO         DQ 18446744073709551615          ; 64-bit integer constant
MAX_FIBO_TERMS   EQU 93                       ; Simple constant
LOCAL_VAR_SPACE  EQU 32                       ; Local variable space in bytes

; Calculate GOLDEN_CONST
GOLDEN_CONST     REAL8  ? ; Double-precision floating-point constant
FIVE             REAL8 5.0                    ; Floating-point constant 5.0
TWO              REAL8 2.0                    ; Floating-point constant 2.0
INIT             REAL8 -1.0

; Enumeration
FB_OK       EQU 0
FB_TMT      EQU 1
FB_TB       EQU 2
FB_PRM_ERR  EQU 3

abs_mask dq 7FFFFFFFFFFFFFFFh  ; Mask with all bits set except the sign bit


.code

_DllMainCRTStartup PROC
    ; Call DllMain (you can add code to handle the reason for the call if necessary)
    mov eax, 1 ; Return 1 (TRUE) to indicate successful initialization.
    ret
_DllMainCRTStartup ENDP

isPrime PROC

    ;push rbx
    push r8
    push r9
   ; push rdx
    ; need prime_number in r12
    ; need maxfactor
    ; rax, rcx, rdx, r8, r9, r10, r11
    mov r8, [rbp - 32]   ; maxFactor

    cmp r12, r8
    jg search ; If numberPrime is greater than or equal to maxFactor
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

    ; Increment the loop counter
    inc rbx

    ; Compare the loop counter with the endpoint
    cmp rbx, r8
    ; Continue looping if rcx is less than rdx
    jl brutPrime

    jmp exit

found:
    mov r9, 0

exit:
    mov rax, r9
   ; pop rdx
    pop r9
    pop r8
   ; pop rbx
    ret
isPrime ENDP

factorization PROC
    ; rax, rcx, rdx, r8, r9, r10, r11
 ;   push r15
 ;   push r14
    push r10
 ;   push r9
 ;   push r8
   push rcx
 ;   push rdx
;    push rbx
    ; need baseIndex in R13
    mov r11, [rbp - 32]   ; maxFactor
    mov r10, [rbp + 56]   ; get the first value of arTerms
    mov r9, [rbp + 64]    ; get the first value of arPrimes

    mov r8, 0 ; position = 0
    mov rbx, 2
    mov rcx, [r10 + 8 * r13] ; rcx = result

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

    ; test si prime
    mov r12, rbx
    call isPrime

   ; si rax = 1 prime sinon rax = 0
    test rax, rax
    jz not_prime_facto
    ; here it is prime we need to modify the value

    mov dl, 1 ; False
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

;    pop rbx
 ;   pop rdx
    pop rcx
 ;   pop r8
 ;   pop r9
    pop r10
 ;   pop r14
  ;  pop r15
    ret
factorization ENDP


fiboWork PROC
 ;   push rcx
 ;   push rdx
 ;   push r10
 ;   push r11
 ;   push r12
 ;   push r13

    mov r10 , [rbp - 16] ; maxterms
    mov rcx, 100
    ; maxTerms - R12
    imul r10, r10, 50
calculate_fibo:
    ; Loop body here
    mov rax, [rbp+56] ; get the value
    mov rdx, 0
    mov r8, [rax + 8 * rcx - 800] ; 50 * 16
    add rdx, r8
    mov r8, [rax + 8 * rcx - 400] ; 50 * 8
    add rdx, r8
    cmp rdx, [rbp - 24]
    jg out_max_fibo
    mov [rax + 8 * rcx], rdx
    mov r12, rdx
    call isPrime

   ; si rax = 1 prime sinon rax = 0
    mov r11, [rbp+64]
    test rax, rax
    jz not_prime
    ; here it is prime we need to modify the value

    mov dl, 1 ; False
    mov [r11 + rcx], dl

not_prime:

    mov r13, rcx
    call factorization

    ; Increment the loop counter
    add rcx,50
    ; Compare the loop counter with the endpoint
    cmp rcx, r10
    ; Continue looping if rcx is less than rdx
    jl calculate_fibo

out_max_fibo:


;    pop r13
;    pop r12
;    pop r11
;    pop r10
;    pop rdx
;    pop rcx
    ret
fiboWork ENDP

clearAndFill PROC

;    push rcx
 ;   push rdx
  ;  push r8
   ; push r9
    ;push r10
    ;push r13

    ; Clear arTerms
    mov r10 , [rbp - 16] ; maxterms
    imul r8, r10, 50
    mov rcx, 0
    mov r9 , [rbp - 8] ; fbstart

loop_unsigned:
    ; Loop body here
    mov rax, [rbp+56]

    mov rdx,0 ; zero
    mov [rax + 8 * rcx], rdx

    mov rax, [rbp+64]
    mov dl, 0 ; False
    mov [rax + rcx], dl

    ; Increment the loop counter
    inc rcx
    ; Compare the loop counter with the endpoint
    cmp rcx, r8
    ; Continue looping if rcx is less than rdx
    jl loop_unsigned


    mov rcx, 0
    ; init the first value with r11 (fbStart)
    mov rax, [rbp+56]
    mov [rax], r9
    mov [rax + 8 * 50], r9
    ; here factorization
    mov r13, 0
    call factorization
    mov r13, 50
    call factorization

loop_double:
    mov rax, [rbp+72]
    movsd xmm0, QWORD PTR [INIT]  ; Load the double value into xmm0
    movsd QWORD PTR [rax + 8 * rcx], xmm0

    ; Increment the loop counter
    inc rcx
    ; Compare the loop counter with the endpoint
    cmp rcx, r10
    ; Continue looping if rcx is less than rdx
    jl loop_double


;    pop r13
 ;   pop r10
  ;  pop r9
   ; pop r8
   ; pop rdx
   ; pop rcx
    ret
clearAndFill ENDP

calculate_error PROC
  ;  push r8
  ;  push r9
  ;  push r10
  ;  push r11
  ;  push r12

    mov r10, [rbp - 16] ; maxterms
    mov r8, [rbp + 72] ; error array
    mov r9, [rbp + 56] ; arTerms array
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
    ; Load GOLDEN_CONST into xmm1
    movsd xmm1, [GOLDEN_CONST]

    ; Subtract GOLDEN_CONST from xmm0
    subsd xmm0, xmm1

    ; absolute value
    movsd xmm1, [abs_mask]  ; Load the mask into xmm1
    andpd xmm0, xmm1        ; Perform bitwise AND to clear the sign bit

    movsd QWORD PTR [r8 + 8 * r11], xmm0

two_first_value:
    ; Increment the loop counter
    inc r11
    ; Compare the loop counter with the endpoint
    cmp r11, r10
    ; Continue looping if rcx is less than rdx
    jl loop_error

    ; Load the address stored in arError (at [rbp+72])
    ; mov rax, [rbp+72]
    ; Load the first double value from the address in rax into xmm0
    ; movsd xmm0, QWORD PTR [rax]
    ; Now xmm0 contains the first element of the arError array
    ; Store this value to the location pointed to by rdx
    ; movsd QWORD PTR [rdx], xmm0


  ;  pop r12
  ;  pop r11
  ;  pop r10
  ;  pop r9
  ;  pop r8
    ret
calculate_error ENDP

fibonacci_interop_asm PROC
    ; Prologue
    push rbp
    mov rbp, rsp
    sub rsp, LOCAL_VAR_SPACE ; Adjust this as needed for your local variables

    ; Save non-volatile registers
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
 ;   push rbx
 ;   push rdi
 ;   push rsi
 ;   push r8
 ;   push r9

    ; Calculate the golden ratio: (1.0 + sqrt(5.0)) / 2.0
    fld1                     ; Load 1.0 onto the FPU stack
    fld QWORD PTR [FIVE]     ; Load 5.0 onto the FPU stack
    fsqrt                    ; Compute sqrt(5.0)
    fadd                     ; Add 1.0 (result: 1.0 + sqrt(5.0))
    fld QWORD PTR [TWO]      ; Load 2.0 onto the FPU stack
    fdiv                     ; Divide (1.0 + sqrt(5.0)) / 2.0
    fstp QWORD PTR [GOLDEN_CONST] ; Store the result in GOLDEN_CONST

    ; Arguments in register store in local
    ; RCX -> fbStart (8 bytes)
    ; RDX -> maxTerms (1 byte)
    ; R8 -> maxFibo (8 bytes)
    ; R9 -> maxFactor (8 bytes)
    mov [rbp - 8], rcx  ; fbStart
    mov [rbp - 16], rdx ; maxTerms
    mov [rbp - 24], r8  ; maxFibo
    mov [rbp - 32], r9  ; maxFactor

    ; Arguments in the stack
    ; Return Address -> (8 bytes) - but 16 bytes alignment
    ; Home space -> (32 bytes) (48)
    ; [rbp+48] -> nbrOfLoops - (8 bytes)
    ; [rbp+56] -> pointer to arTerms (unsigned long long*) - (8 bytes)
    ; [rbp+64] -> pointer to arPrimes (bool*) - (8 bytes)
    ; [rbp+72] -> pointer to arError (double*) - (8 bytes)
    ; [rbp+80] -> reference to goldenNbr - (8 bytes)


    ; - Some verification
    ; Load the values of fbStart, maxFibo, maxTerms, maxFactor, and nbrOfLoops into registers
    mov rax, rcx       ; Load fbStart into rax
    mov rcx, rdx       ; Load maxTerms into rcx
    mov rbx, r8        ; Load maxFibo into rbx
    mov rdx, r9        ; Load maxFactor into rdx
    xor rsi, rsi          ; Zero out rax
    movzx rsi, byte ptr [rbp+48] ; Move 1 byte from [rbp+48] and zero-extend to 64-bit

    ; Check conditions and return PRM_ERR if any condition is true
    cmp rax, 1          ; Compare fbStart with 1
    jl prm_err_label    ; Jump to prm_err_label if fbStart < 1

    cmp rbx, 1          ; Compare maxFibo with 1
    jl prm_err_label    ; Jump to prm_err_label if maxFibo < 1

    cmp rcx, 3          ; Compare maxTerms with 3
    jl prm_err_label    ; Jump to prm_err_label if maxTerms < 3

    cmp rdx, 2          ; Compare maxFactor with 2
    jl prm_err_label    ; Jump to prm_err_label if maxFactor < 2

    cmp rsi, 1          ; Compare nbrOfLoops with 1
    jl prm_err_label

    cmp rcx, 74          ; Compare maxTerms with 74
    jg tmt_label

    mov rax, MAX_FIBO
    cmp rbx, rax
    jg too_big_label

    cmp rdx, rax
    jg too_big_label

    ; fill the array with value
    ; number of loop is still in rsi
    xor rcx,rcx

main_loop:
    call clearAndFill
    call fiboWork
    call calculate_error
    ; Increment the loop counter
    inc rcx
    ; Compare the loop counter with the endpoint
    cmp rcx, rsi
    jl main_loop


    mov rdx, [rbp+80]
    movsd xmm0, QWORD PTR [GOLDEN_CONST]
    movsd QWORD PTR [rdx], xmm0
    ;mov r12, 5
    ;call isPrime
    ;mov r10, [rbp+88]
    ;mov [r10], rax

    xor rax,rax
    ; test
    ; Load the value 1.234567 into xmm0
    ; movsd xmm0, QWORD PTR [GOLDEN_CONST]
    ; movsd QWORD PTR [rdx], xmm0  ; Store the value in xmm0 into the location pointed to by rdx

    ;xor rax, rax          ; Zero out rax
    ;movzx rax, byte ptr [rbp+48] ; Move 1 byte from [rbp+48] and zero-extend to 64-bit
    ;mov [r10], rax        ; Store the value in rax to the location pointed to by r10

    ; Load the address stored in arTerms into a register (e.g., rax)
    ; mov rax, [rbp+56]

    ; Dereference the pointer to access the first element of the array
    ; Assuming arTerms points to an array of unsigned long long (8 bytes each)
    ; mov rax, [rax]
    ; mov [r10], [rax]

    ; Load the address stored in arPrimes (at [rbp+64]) into rax
    ; mov rax, [rbp+64]

    ; Dereference the pointer to access the first element of the array
    ; Since arPrimes points to an array of bools (1 byte each), use a byte-sized move
    ; movzx rax, byte ptr [rax]

    ; Now, rax contains the value of the first element of the arPrimes array (as a byte)
    ; Store this value in the location pointed to by r10
    ; mov [r10], rax

    ; Load the address stored in arError (at [rbp+72])
    ; mov rax, [rbp+72]
    ; Load the first double value from the address in rax into xmm0
    ; movsd xmm0, QWORD PTR [rax]
    ; Now xmm0 contains the first element of the arError array
    ; Store this value to the location pointed to by rdx
    ; movsd QWORD PTR [rdx], xmm0

no_error:
    mov rax,  FB_OK  ; Set rax to the value corresponding to fbReturn::OF
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
    ; Epilogue
    ; Restore non-volatile registers
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

    ; Return value in rax (set this according to your function's logic)
    ret
fibonacci_interop_asm ENDP

end
; Indique la fin du fichier source.
