.data
MAX_FIBO         DQ 1304969544928657          ; 64-bit integer constant
MAX_FIBO_TERMS   EQU 74                       ; Simple constant
LOCAL_VAR_SPACE  EQU 32                       ; Local variable space in bytes

; Calculate GOLDEN_CONST
GOLDEN_CONST     REAL8  ? ; Double-precision floating-point constant
FIVE             REAL8 5.0                    ; Floating-point constant 5.0
TWO              REAL8 2.0                    ; Floating-point constant 2.0

; Enumeration
FB_OK       EQU 0
FB_NOL      EQU 1
FB_OF_P     EQU 2
FB_OF       EQU 3
FB_TMT      EQU 4
FB_TB       EQU 5
FB_PRM_ERR  EQU 6
FB_ERR      EQU 7

.code

fibonacci_interop_asm PROC
    ; Prologue
    push rbp
    mov rbp, rsp
    sub rsp, LOCAL_VAR_SPACE ; Adjust this as needed for your local variables

    ; Save non-volatile registers (if used)
    push rbx
    push rdi
    push rsi
    push r8
    push r9
    push r10
    push r11

    ; Calculate the golden ratio: (1.0 + sqrt(5.0)) / 2.0
    fld1                     ; Load 1.0 onto the FPU stack
    fld QWORD PTR [FIVE]     ; Load 5.0 onto the FPU stack
    fsqrt                    ; Compute sqrt(5.0)
    fadd                     ; Add 1.0 (result: 1.0 + sqrt(5.0))
    fld QWORD PTR [TWO]      ; Load 2.0 onto the FPU stack
    fdiv                     ; Divide (1.0 + sqrt(5.0)) / 2.0
    fstp QWORD PTR [GOLDEN_CONST] ; Store the result in GOLDEN_CONST

    ; Arguments in register
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
    ; [rbp+56] -> pointer to arTerms - (8 bytes)
    ; [rbp+64] -> pointer to arPrimes - (8 bytes)
    ; [rbp+72] -> pointer to arError - (8 bytes)
    ; [rbp+80] -> reference to goldenNbr - (8 bytes)
    ; [rbp+88] -> reference to test - (8 bytes)

    // - Every register is ready to work




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

error:
    mov rax,  FB_NOL  ; Set rax to the value corresponding to fbReturn::OF
    jmp epilogue


epilogue:
    ; Epilogue
    ; Restore non-volatile registers
    pop r11
    pop r10
    pop r9
    pop r8
    pop rsi
    pop rdi
    pop rbx

    ; Restore original rsp
    mov rsp, rbp
    pop rbp

    ; Return value in rax (set this according to your function's logic)
    ret
fibonacci_interop_asm ENDP

end
; Indique la fin du fichier source.
