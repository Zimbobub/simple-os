; change directory

; temporarily uses sector numbers as arg
; also only supports 1 digit sector nums as i havent added BCD yet

push ax
push si

; shift the command away
add si, 3

; get the int value of arg
mov ax, [si]
sub ax, '0'

; set working dir
call setWorkingDirectory

; return
pop si
pop ax

jmp main