section .text

global _start

_start: jmp main

;-----------------------------------------------------------------------------
; Prints string to stdout
;-----------------------------------------------------------------------------
%macro  prStdout 2
        mov rax, 0x01   ; stdout
        mov rdi, 1      ; func id
        mov rsi, %1     ; rsi (pointer to str)
        mov rdx, %2     ; rdx (msgLen)
        syscall
%endmacro

;-----------------------------------------------------------------------------
           ; a      b      c      d    e
cases:  dq def, procB, procC, procD, def
           

procB:
        prStdout BMsg, BMsgLen
        ret

procC:
        prStdout CMsg, CMsgLen
        ret

procD:
        ret

def:
        prStdout DefMsg, DefMsgLen
        ret
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
; Takes string format and any amount of arguments to print
;---------------------------------------------------------------------------- 
; Entry:        rax - amount of arguments
;               rbx - pointer to string with symbols
;               [temp] rcx - value to print   
;----------------------------------------------------------------------------  
printf:
        sub rcx, 0x61
        shl rcx, 0x3
        mov rdx, cases[rcx]
        jmp rdx
        ret


main: 
        mov rcx, 0x62
        call printf

        mov rax, 0x3C
        syscall                 ; exit()


section .data

DefMsg:   db  "Looser", 0x0A
DefMsgLen equ $ - DefMsg

BMsg:     db  "B", 0x0A
BMsgLen   equ $ - BMsg

CMsg:     db  "C", 0x0A
CMsgLen   equ $ - CMsg
