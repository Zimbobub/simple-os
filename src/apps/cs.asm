; change sector
; old version of 'cd' that uses sector num as input

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