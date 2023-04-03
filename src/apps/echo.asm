; echo
; prints back whatever args you give it

add si, 5           ; skip past "echo " so we only print the args
call puts
sub si, 5

; print newline
push ax
mov al, 0x0D
call putc
mov al, 0x0A
call putc
pop ax

; return
jmp main