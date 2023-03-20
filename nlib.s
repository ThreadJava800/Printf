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
                popar

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
; Print hex of value
;-----------------------------------------------------------
; Entry:        [RBP] = value to convert to
; Exit:		None
; Expects:  	None
; Destroys: 	RBX, RCX, RDX, RSI, RDI
;----------------------------------------------------------
ToHex:
            mov rsi, [rbp]
            mov rcx, 0x10			    ; amount of numbers in hex val
            mov rbx, zerBuf + 0x0F      ; end of buffer

.Loop:			
            mov rdi, 0x0F 			    ; byte mask
            and rdi, rsi 				; first num

            mov dl, [symbArr + rdi]     ; getting symbol
            mov byte [rbx], dl          ; writing symbol to buf

            dec rbx                     ; rbx--

            cmp rsi, 0
            je .Exit                    ; exit if numbers ended

            shr rsi, 4                  ; rsi //= 16
            loop .Loop

.Exit:
            mov rbx, 0x10
            sub rbx, rcx                ; amount of values to print

            mov r10, zerBuf
            add r10, rcx                ; rax = pointer to beginning of decimal
            prStdout r10, rbx
            ret

;-----------------------------------------------------------
; Print binary of value
;-----------------------------------------------------------
; Entry:        RAX = value to convert to
; Exit:		None
; Expects:  	None
; Destroys: 	RAX, RBX, RCX, RDX
;-----------------------------------------------------------
ToBin:
            mov rax, [rbp]               ; [rbp] -> rax
            mov rcx, 0x40                ; counter = 65 (max 64 digits)
            mov rbx, zerBuf + 0x3F       ; setting rbx to end of buffer

.Loop:      
            mov rdx, 0x01               ; flag to and with
            and rdx, rax                ; rdx = rdx & rax (first bit)

            add rdx, 0x30               ; rdx += 30 to get ascii
            mov byte [rbx], dl          ; put ascii to buffer

            dec rbx                     ; rbx--

            cmp rax, 0
            je .Exit                    ; exit if digits ended

            shr rax, 0x1                ; rax //= 2
            loop .Loop

.Exit:      
            mov rbx, 0x40
            sub rbx, rcx                ; amount of values to print

            mov r10, zerBuf
            add r10, rcx                ; rax = pointer to beginning of decimal
            prStdout r10, rbx
            ret


;-----------------------------------------------------------
; Print oct of value
;-----------------------------------------------------------
; Entry: 	[RBP] = value to convert to
; Exit:		None
; Expects:  	None
; Destroys: 	RAX, RBX, RCX, RDX
;-----------------------------------------------------------
ToOct:
                mov rax, [rbp]
                mov rcx, 0x15           ; amount of digits (21)
                mov rbx, zerBuf + 0x14  ; end of buf

.Loop:
                mov rdx, 0x07           ; bit mask (last 3 values)
                and rdx, rax            ; rdx = 3 last values

                add rdx, 0x30           ; convert to ascii
                mov byte [rbx], dl      ; push to buffer

                dec rbx                 ; rbx--

                cmp rax, 0
                je .Exit

                shr rax, 0x03           ; rax >> 3
                loop .Loop

.Exit:          
                mov rbx, 0x15
                sub rbx, rcx                ; amount of values to print

                mov r10, zerBuf
                add r10, rcx                ; rax = pointer to beginning of decimal
                prStdout r10, rbx
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