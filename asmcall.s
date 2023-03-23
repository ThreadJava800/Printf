section .text
; USE FOR CALL FROM ASSEMBLY
global main

main:
    call kernel32connect
    ret

extern kernel32connect