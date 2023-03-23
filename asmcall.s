extern kernel32connect

section .text
; USE FOR CALL FROM ASSEMBLY
global main

main:
    mov eax, 0
    mov rdi, format
    mov rsi, 120
    mov rdx, 120
    mov rcx, 120
    mov r8,  text1
    mov r9,  0x31

    push 12
    push 16

    call kernel32connect

    pop r10
    pop r10
    
    ret

section .data

format: db "Test %d %x %o %s %c hello %d %d", 0x0A, 0x00

text1:  db "R8Text"