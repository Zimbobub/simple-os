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
    jnz .takenError

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
        jmp .fsFullError

    ; allocate space in the OSINFO sector
    .allocateDir:
        ; sector is now stored in BX
        push bx ; save BX as we will modify it
        add bx, OSINFO      ; offset the OSINFO address by BX

        mov al, 0b10000001  ; default directory info (used, non-exec, non-prot, 1 entry)
        mov byte [bx], al   ; save it in OSINFO

        pop bx

    ; init an empty directory
    .createDir:



    .exit:
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret

    .takenError:
        mov si, .takenErrorMsg
        call puts
        jmp .exit
    .takenErrorMsg: db 'Error: Directory already exists!', ENDL, 0

    .dirFullError:
        mov si, .dirFullError
        call puts
        jmp .exit
    .dirFullErrorMsg: db 'Error: Parent directory is full!', ENDL, 0

    .fsFullError:
        mov si, .fsFullError
        call puts
        jmp .exit
    .fsFullErrorMsg: db 'Error: File system is full!', ENDL, 0