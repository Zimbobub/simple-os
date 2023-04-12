; functions for creating files/folders



; creates an empty directory inside the specified directory
; param:
; AX: parent directory sector
; SI: pointer to name
createDirectory:
    push ax
    push bx
    push cx
    push dx
    push si

    ; check if the directory's name is taken
    mov bx, ax      ; BX: sector # to search through
                    ; SI: pointer to name string    (must be null terminated)
    call findSectorByName
    ; returns:
    ; AX: sector # we found (0 if not found)
    ; if it is zero, the name is free & we can continue
    or ax, ax
    jnz .error

    ; TODO: check if directory is full (31 entries)

    ; find an open sector
    mov bx, ROOT_DIRECTORY_SECTOR   ; current sector we are checking
    mov cx, 117     ; 117 possible sectors to use (fs size)
    .findOpenSector:
        mov ax, bx          ; getSectorInfo expects the sector in AX
        call getSectorInfo  ; returns the sector info in AL

        cmp byte al, 0      ; if the sectorinfo is null, the sector is empty
        je .allocateDir

        ; otherwise loop again
        inc bx
        loop .findOpenSector
        ; if we reach here the FS is full
        jmp .error

    ; allocate space in the OSINFO sector
    .allocateDir:
        mov ax, bx
        call printU16Hex

    ; init an empty directory
    .createDir:



    .exit:
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret

    .error:
        ; TODO: error msgs
        jmp .exit