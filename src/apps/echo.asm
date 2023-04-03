; echo
; implement later once args are working
call puts
; print newline
push ax
mov al, 0x0D
call putc
mov al, 0x0A
call putc
pop ax
jmp main