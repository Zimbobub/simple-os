; dumps the ascii contents of a file to stdout

push ax
push bx
push cx
push si

; shift the command away
add si, 5

; get the sector number, returns to AX
; BX: sector to search
; SI: filename to search for
mov bx, [WORKING_DIRECTORY_INFO]
call findSectorByName

; get the memory location of that file & put the pointer into SI
call getSectorMemoryLocation
mov si, ax

; loop over each char and print it
mov cx, 512             ; 512 chars max in file, exit early on null char
.loop:
    mov byte al, [si]   ; read next char from memory

    ; if char is null, exit as we reached EOF
    or al, al
    jz .exit

    ; otherwise print the char
    call putc

    ; check for \n
    cmp al, 0x0A
    jne .next       ; if not, loop again
    mov al, 0x0D    ; if yes, print a carriage return
    call putc

    .next:
        ; increment pointer & loop
        inc si
        loop .loop

.exit:
    call newline

    pop si
    pop cx
    pop bx
    pop ax
    jmp main