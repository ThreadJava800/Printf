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
        mov cl, 0x01
        call ToBinDeg
        jmp RtnCase

procC:
        mov rbx, [rbp]
        mov [oneChar], rbx
        prStdout oneChar, 1
        jmp RtnCase

procD:
        call ToDec
        jmp RtnCase

procO:
        mov cl, 0x03
        call ToBinDeg
        jmp RtnCase

procS:
        call PrintString
        jmp RtnCase

procX:
        mov cl, 0x04
        call ToBinDeg
        jmp RtnCase

procPcnt:
        mov qword [oneChar], "%"

        pushar
        prStdout oneChar, 1
        popar

        ret                ; return from switch function!

def:
        shr rax, 0x03
        add rax, 0x61                           ; getting value from address -> al

printErr:
        mov byte [DefMsg + DefMsgLen - 3], '%'
        mov byte [DefMsg + DefMsgLen - 2], al

        prStdout DefMsg, DefMsgLen
        exit
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
; Switch-case handler. Takes symbol and parses it.
;----------------------------------------------------------------------------
; Entry:        rax - symbol to print
; Expects:      None
; Exit:         None
; Destroys:     rdx, rbp
;----------------------------------------------------------------------------
Swtch:
        mov al, byte [rdi]      ; al = symbol to jump

        cmp rax, "%"            ; if one more % met: print %
        je procPcnt

        cmp al, 0x61
        jb printErr

        cmp al, 0x78
        ja printErr             ; if al < 'a' || al > 'x' drop err

        sub rax, 0x61           ;      [ascii to ind]     
        shl rax, 0x03           ; al = (al - 61) * 8 (indexing jmp arr)
        mov rdx, cases[rax]     ; rdx = place where to jump

        pushar                  ; push rax, rbx, rcx, rdx, rsi, rdi
        jmp rdx                 ; jmping on case

RtnCase:        
        popar                   ; pop some of (:68) 64-bit regs
        add rbp, 8              ; moving bp forward to next argument

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
        mov  rbp, rsp            ; sp -> bp
        add  rbp, 8 * 2          ; bp -= 2 registers -> first argument

        mov  r10, rdi            ; r10 = start of string to print except of %

.stLoop:
        mov al, byte [rdi]      ; al = symbol from rdi
        inc rdi                 ; rdi++

        cmp al, "%"             ; if al == '%': jmp
        je  .mkJmp

        cmp rax, 0x24           ; if al == $ return
        je  .Exit

        jmp .stLoop             ; else: repeat

.mkJmp:
        pushar

        mov rcx, rdi
        sub rcx, r10            ; rcx = rdi - r10 (length of str)
        dec rcx

        prStdout r10, rcx       ; print string before %
        popar
        mov r10, rdi
        inc r10

        call Swtch              ; parse %

        xor rax, rax            ; rax = 0
        inc rdi                 ; rdi++

        jmp .stLoop             ; else continue

.Exit:  
        mov rcx, rdi
        sub rcx, r10            ; rcx = rdi - r10 (length of str)
        dec rcx

        prStdout r10, rcx       ; print string before %

        pop rbp
        ret


;--------------------------------------------------------------
; Just main function
; Calls printf function to parse fmt
;--------------------------------------------------------------
main: 
        mov rdi, format
        push '1'
        push 16
        push 16
        push 16
        push BMsg
        push 123

        call printf

        exit


section .data

DefMsg:   db  "Unknown flag: ", 0, 0, 0x0A
DefMsgLen equ $ - DefMsg

BMsg:     db  "Hello B$"
BMsgLen   equ $ - BMsg

CMsg:     db  "C", 0x0A
CMsgLen   equ $ - CMsg

format:   db "FMT STR: %d %s %x %o test %d %1 %c", 0x0A, '$'
formatLen equ $ - format


oneChar:  db 0
