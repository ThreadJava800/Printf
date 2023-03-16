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

section .data
zerBuf:     times 16 db 0

section .text

;-----------------------------------------------------------
; Print dec of value
;-----------------------------------------------------------
; Entry: 	    RAX = value to convert to
; Exit:		    None
; Destroys: 	RAX, RBX, RCX, RDX, RDI
;-----------------------------------------------------------
ToDec:
	
			mov rcx, 0x4		      ; amount of digits (16d)
            mov rbx, zerBuf + 0x4     ; rbx = end of zerobuf
	
.PrintSymb:
			mov rdi, 0xA		; rcx = 10
			div rdi				; rax = rax / 10, rdx = rax % 10
				
			add rdx, 0x30		; edx += 30 (symb ascii)

			mov byte [rbx], dl      ; add to buffer
            dec rbx			    ; bx --

			xor rdx, rdx        ; rdx = 0

            cmp rax, 0
            je .Exit            ; exit if no more digits in number

			loop .PrintSymb

.Exit:		
            mov rbx, 0x5
            sub rbx, rcx        ; amount of values to print

            mov r10, zerBuf
            add r10, rcx        ; rax = pointer to beginning of decimal
            prStdout r10, rbx
            ret

section .data
symbArr:   db "0123456789ABCDEF"

section .text
;-----------------------------------------------------------
; Print hex of value
;-----------------------------------------------------------
; Entry: 		SI = value to convert to
; Exit:			None
; Expects:  	None
; Destroys: 	RBX, RCX, RDX, RSI, RDI
;----------------------------------------------------------
ToHex:
            mov rcx, 0x08			    ; amount of numbers in hex val
            mov rbx, zerBuf + 0x07      ; end of buffer

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
            mov rbx, 0x08
            sub rbx, rcx                ; amount of values to print

            mov r10, zerBuf
            add r10, rcx                ; rax = pointer to beginning of decimal
            prStdout r10, rbx
            ret

;-----------------------------------------------------------
; Print binary of value
;-----------------------------------------------------------
; Entry: 		RAX = value to convert to
; Exit:			None
; Expects:  	None
; Destroys: 	RAX, RBX, RCX, RDX
;-----------------------------------------------------------
ToBin:
            mov rcx, 0x10               ; counter = 15 (max 16 digits)
            mov rbx, zerBuf + 0xF       ; setting rbx to end of buffer

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
            mov rbx, 0x10
            sub rbx, rcx                ; amount of values to print

            mov r10, zerBuf
            add r10, rcx                ; rax = pointer to beginning of decimal
            prStdout r10, rbx
            ret