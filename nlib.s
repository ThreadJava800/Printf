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
; Destroys: 	RAX, RBX, RCX, RDX
;-----------------------------------------------------------
ToDec:
	
			mov rcx, 0xF		      ; amount of digits (16d)
            mov rbx, zerBuf + 0xF     ; rbx = end of zerobuf
	
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
            mov rbx, 0x10
            sub rbx, rcx        ; amount of values to print

            mov r10, zerBuf
            add r10, rcx        ; rax = pointer to beginning of decimal
            prStdout r10, rbx
            ret