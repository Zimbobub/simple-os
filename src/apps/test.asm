; test
; does whatever we need to for testing features


push ax

mov ax, 123
call printU8Decimal


pop ax

jmp main
