; list directory
; get RAM address of the sector we want
; current directory stored at WORKING_DIRECTORY_INFO


push ax
push cx
push si

; get the working directory
mov si, WORKING_DIRECTORY_INFO
mov ax, [si]

; get the ram address of the working dir
; func expects arg in AX and returns to AX
call getSectorMemoryLocation
mov si, ax

; loop over 32 entries
mov cx, 32
.loop:
    ; get the sector # of the entry
    mov byte al, [si]

    ; check if it is empty
    or al, al
    jz .end

    ; otherwise, print it & continue
    call printU8Hex

    ; print a separator
    mov al, ' '
    call putc
    mov al, ':'
    call putc
    mov al, ' '
    call putc

    ; print the name of the file/folder
    inc si          ; move si over 1
    push cx         ; save cx as we use it in this func
    mov cx, 15      ; print 15 chars
    call putsLen
    pop cx          ; restore cx
    add si, 15      ; move SI to the next entry

    ; print newline
    call newline

    loop .loop      ; loop 32 times

.end:
    pop si
    pop cx
    pop ax

    jmp main