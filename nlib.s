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
; Pushes some of 64 bit registers
;-----------------------------------------------------------------------------
%macro  pushar 0

        push rax
        push rbx
        push rcx
        push rdx
        push rsi
        push rdi
        push r10
        
%endmacro

;-----------------------------------------------------------------------------
; Pops some of 64 bit registers
;-----------------------------------------------------------------------------
%macro  popar 0

        pop r10
        pop rdi
        pop rsi
        pop rdx
        pop rcx
        pop rbx
        pop rax
        
%endmacro

;-------------------------------------------------------------------------------
%macro exit 0
        mov rax, 0x3C
        syscall                 ; exit()
%endmacro
;-------------------------------------------------------------------------------

section .data
zerBuf:     times 64 db 0

section .text

;-----------------------------------------------------------
; Print dec of value
;-----------------------------------------------------------
; Entry: 	    [RBP] = value to convert to
; Exit:		    None
; Destroys: 	    RAX, RBX, RCX, RDX, RDI, R10, R11
;-----------------------------------------------------------
ToDec:
                mov rax, [rbp]                ; moving from [rbp] to rax

                mov r10, 0x01                   
                shl r10, 63d                  ; setting r10 = 1 and 63 0 (bin)
                and r10, rax                  ; flag if rax is negative or not

                cmp r10, 0x00
                je .ParsePos

                neg rax                       ; if rax < 0 rax = abs(rax)

.ParsePos:
                mov rcx, 0x12		      ; amount of digits (16d)
                mov rbx, zerBuf + 0x12        ; rbx = end of zerobuf

                xor rdx, rdx                  ; rdx = 0
	
.PrintSymb:
                mov rdi, 0xA		      ; rcx = 10
                div rdi			      ; rax = rax / 10, rdx = rax % 10
                                        
                add rdx, 0x30		      ; edx += 30 (symb ascii)

                mov byte [rbx], dl            ; add to buffer
                dec rbx			      ; bx --

                xor rdx, rdx                  ; rdx = 0

                cmp rax, 0
                je .Exit                      ; exit if no more digits in number

                loop .PrintSymb

.Exit:		
                cmp r10, 00
                je .PrintPos

                pushar
                mov rbx, "-"
                mov [oneChar], rbx
                prStdout oneChar, 1
                popar                         ; print '-' if value is hegative

.PrintPos:               
                mov rbx, 0x13
                sub rbx, rcx                  ; amount of values to print

                mov r10, zerBuf
                add r10, rcx                  ; rax = pointer to beginning of decimal
                prStdout r10, rbx
                ret

section .data
symbArr:   db "0123456789ABCDEF"

section .text
;-----------------------------------------------------------
; Prints any binary degree of value to screen
;-----------------------------------------------------------
; Entry:        [RBP] = value to convert to
;               CL    = degree of scale (1 - bin, 3 - oct, 4 - hex etc.)
; Exit:		None
; Expects:  	None
; Destroys: 	RBX, DL, RSI, RDI, R10
;----------------------------------------------------------
ToBinDeg:
        mov rsi, [rbp]                  ; copy value to rsi from memory
        mov rbx, zerBuf + 0x40          ; end of buffer

.Loop:
        mov rdi, 0x01
        sal rdi, cl                     ; rdi = bytemask
        dec rdi                         ; rdi-- to make all 1

        and rdi, rsi                    ; rdi = first number to print

        mov dl, [symbArr + rdi]         ; dl = symbol from arr
        mov byte [rbx], dl              ; put symbol to mem

        cmp rsi, 0x00
        je .Exit                        ; if value = 0: exit

        dec rbx                         ; and rbx-- (pointer to buffer)
        sar rsi, cl
        jmp .Loop                       ; rsi //= 2 * dl and continue

.Exit:
        mov r10, zerBuf + 0x40          ; address of end
        sub r10, rbx                    ; r10 = end - cur + 1 (amount of symbols)

        inc rbx                         ; rbx++ to print from real start
        prStdout rbx, r10
        ret


;-----------------------------------------------------------------------------
; Entry:    RBX - pointer to string
; Exit:     None
; Expects:  None
; Destroys: RAX, RBX
;-----------------------------------------------------------------------------
PrintString:
            mov rbx, [rbp]            ; rbx addr = pointer to str

.PrSymb:    
            mov byte al, [rbx]

            cmp al, "$"
            je .Exit                  ; if \0 met return

            prStdout rbx, 1           ; print 1 symbol
            inc rbx

            jmp .PrSymb

.Exit:      ret