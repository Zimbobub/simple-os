; change directory

; TODO: add special cases for root directory

push ax
push bx
push si

; shift the command away
add si, 3

; check if user inputted '/', short for root dir
mov byte al, [si]
cmp al, '/'
je .rootDir


; else, search for the directory

; get the sector number
; BX: sector to search
; SI: filename to search for
; return:
; AX: sector number (0 if not found)
mov bx, [WORKING_DIRECTORY_INFO]
call findSectorByName

; if directory not found, print error & exit
or ax, ax
jz .error

; set working dir
; AX: sector number (already set by above function)
call setWorkingDirectory

.exit:
    pop si
    pop bx
    pop ax

    jmp main



; if user inputted 'cd /'
.rootDir:
    mov ax, ROOT_DIRECTORY_SECTOR
    call setWorkingDirectory
    jmp .exit



.error:
    mov si, .errmsg
    call puts
    jmp .exit

.errmsg: db 'Error: directory does not exist', ENDL, 0