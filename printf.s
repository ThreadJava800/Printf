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
        mov rbx, [rbp]
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
        call PrintString
        ret

procX:
        call ToHex
        ret

def:
        prStdout DefMsg, DefMsgLen
        ret
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
; Switch-case handler. Takes symbol and parses it.
;----------------------------------------------------------------------------
; Entry:        rax - symbol to print
; Expects:      None
; Exit:         None
; Destroys:     rdx
;----------------------------------------------------------------------------
Swtch:
        ret

;----------------------------------------------------------------------------
; Takes string format and any amount of arguments to print
;---------------------------------------------------------------------------- 
; Entry:        rax - amount of arguments
;               rbx - pointer to string with symbols
;               [temp] rcx - value to print   
;----------------------------------------------------------------------------  
printf:
        push rbp                 ; saving all bp
        mov rbp, rsp             ; sp -> bp
        add bp, 8 * 2            ; bp -= 2 registers -> first argument

.stLoop:
        mov al, byte [rdi]      ; al = symbol from rdi
        inc rdi                 ; rdi++

        cmp al, "%"             ; if al == '%': jmp
        je  .mkJmp

        jmp .stLoop             ; else: repeat

.mkJmp:
        mov al, byte [rdi]      ; al = symbol to jump
        sub rax, 0x61           ;      [ascii to ind]     
        shl rax, 0x03           ; al = (al - 61) * 8 (indexing jmp arr)
        mov rdx, cases[rax]

        pushar                  ; push rax, rbx, rcx, rdx, rsi, rdi
        call rdx                ; calling needed
        popar                   ; pop some of (:79) 64-bit regs
        add bp, 8               ; moving bp backwards

        xor rax, rax            ; rax = 0
        inc rdi                 ; rdi++

        mov al, byte [rdi]      ; al - next symbol
        cmp rax, 0x24           ; if al ==  return
        je  .Exit

        jmp .stLoop             ; else continue

.Exit:  
        pop rbp
        ret


;--------------------------------------------------------------
; Just main function
; Calls printf function to parse fmt
;--------------------------------------------------------------
main: 
        mov rdi, format
        push '2'
        push 123
        push BMsg
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

format:   db "Hello, %s %x %c$"
formatLen equ $ - format


oneChar:  db 0
