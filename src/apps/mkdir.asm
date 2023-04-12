; mkdir
; creates a new directory in the working directory

push ax
push si

add si, 6
mov ax, [WORKING_DIRECTORY_INFO]    ; offset of 0 is the working dir's sector #
call createDirectory

pop si
pop ax
jmp main
