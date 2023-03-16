section .text

global _start

_start: jmp main

%include "nlib.s"

;-----------------------------------------------------------------------------
        ;    a      b      c      d
cases:  dq def, procB, procC, procD
        ; e   -    n   
        times 10 dq def
        ;      o
        dq procO
        ; p   -    r  
        times 3 dq def 
        ;      s
        dq procS
        ; t   -    w   
        times 4 dq def 
        ;      x
        dq procX
           

procB:
        call ToBin
        ret

procC:
        mov [oneChar], rbx
        prStdout oneChar, 1
        ret

procD:
        call ToDec
        ret

procO:
        call ToOct
        ret

procS:
        call PrintString                ; rbx
        ret

procX:
        call ToHex
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
        mov rcx, 's'
        mov rax, 31
        mov rsi, 31
        mov rbx, BMsg
        call printf

        mov rax, 0x3C
        syscall                 ; exit()


section .data

DefMsg:   db  "Looser", 0x0A
DefMsgLen equ $ - DefMsg

BMsg:     db  "Hello B", 0x0A, "$"
BMsgLen   equ $ - BMsg

CMsg:     db  "C", 0x0A
CMsgLen   equ $ - CMsg

format:   db "Hello, %d"

oneChar:  db 0
