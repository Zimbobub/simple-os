; mkdir
; creates a new directory in the working directory

push ax
push si

add si, 6

; check if there was no argument ([SI] will be null)
mov byte al, [si]
or al, al
jz .noArgError

mov ax, [WORKING_DIRECTORY_INFO]    ; offset of 0 is the working dir's sector #
call createDirectory

.exit:
    pop si
    pop ax
    jmp main

.noArgError:
    mov si, .noArgErrorMsg
    call puts
    jmp .exit
.noArgErrorMsg: db 'Please specify a name for the directory', ENDL, 0