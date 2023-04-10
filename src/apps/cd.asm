; change directory

; TODO: add special cases for root directory

push ax
push bx
push si

; shift the command away
add si, 3

; get the sector number
; BX: sector to search
; SI: filename to search for
mov bx, [WORKING_DIRECTORY_INFO]
call findSectorByName

; set working dir
; AX: sector number (already set by above function)
call setWorkingDirectory

; return
pop si
pop bx
pop ax

jmp main