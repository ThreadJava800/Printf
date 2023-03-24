; USE FOR CALL FROM CPP
global adapterToC

section .text

; USE FOR CALL FROM ASSEMBLY
; global _start
; _start: jmp main

%include "nlib.s"

section .rodata
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
;------------------------------------------------------------------------------

section .text
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
        mov byte [oneChar], "%"

        pushar
        prStdout oneChar, 1
        popar

        ret                                     ; return from switch function!

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
; Entry:        [CDECL] - last in stack fmt, then arguments in correct order
; Expects:      None
; Exit:         None
; Destroys:     None
;----------------------------------------------------------------------------  
asmPrintf:
        push rbp                 ; saving all bp
        pushar                   ; save all

        mov  rbp, rsp            ; rsp -> rbp
        add  rbp, 8 * 9          ; rbp -= 9 registers -> fmt

        mov  rdi, [rbp]          ; setting rdi = address of fmt str
        mov  r10, rdi            ; r10 = start of string to print except of %

        add rbp, 8               ; moving rbp -> first argument

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

        popar
        pop rbp                 ; getting al back
        ret


;--------------------------------------------------------------
; Just main function
; Calls printf function to parse fmt
;--------------------------------------------------------------
main: 
        push 127d
        push 33d
        push 100d
        push 3802d
        push love_str
        push -1
        push format

        call asmPrintf

        exit


adapterToC:
        pop r10         ; return addr from c func

        push r9         ; arg 6
        push r8         ; arg 5
        push rcx        ; arg 4
        push rdx        ; arg 3
        push rsi        ; arg 2
        push rdi        ; arg1

        call asmPrintf

        pop rdi
        pop rsi
        pop rdx
        pop rcx
        pop r8
        pop r9

        push r10        ; pushing return back

        ret


section .data

DefMsg:   db  "Unknown flag: ", 0, 0, 0x0A
DefMsgLen equ $ - DefMsg

love_str: db "love$"

CMsg:     db  "C", 0x0A
CMsgLen   equ $ - CMsg

format:   db "-What should you love?", 0Ah, \
                 "%d %s %x %d%%%c%b", 0Ah, '$'

oneChar:  db 0
