global start

section .text
bits 32
start:
    ; print 'Hi from Ix OS'
    mov dword [0xb8000], 0x2f692f48 ; Hi
    mov dword [0xb8004], 0x2f662f20 ;  f
    mov dword [0xb8008], 0x2f6f2f72 ; ro
    mov dword [0xb800c], 0x2f202f6d ; m 
    mov dword [0xb8010], 0x2f782f49 ; Ix
    mov dword [0xb8014], 0x2f4f2f20 ;  O
    mov dword [0xb8018], 0x2f002f53 ; S
    hlt
