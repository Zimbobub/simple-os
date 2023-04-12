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

    ; save parent folder for later
    push ax

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
        ; get the memory address of the new directory (BX)
        mov ax, bx
        call getSectorMemoryLocation
        mov bx, ax
call printU16Hex
call newline

        pop ax      ; restore parent directory
        xor ah, ah  ; zero the upper byte, just in case
call printU8Hex


        ; AX: parent dir sector
        ; BX: new dir sector

        ; dir will be initialized with 1 entry (parent folder)
        ; entry format (our case 3 bytes):
        ; [parent dir ptr] '.' '.'
        mov byte [bx], al       ; move pointer of parent dir to dirEntry[0]
        mov byte [bx + 1], '.'  ; save parent dir name '..'
        mov byte [bx + 2], '.'

        ; convert BX back into sector number
        push ax
        mov ax, bx
        call getMemoryLocationSector
        mov bx, ax
        pop ax


    ; create a file entry in the parent directory
    .createEntryInParentDir:
    ; AX: directory to put file entry into
    ; BX: sector to point to
    ; SI: pointer to name
    ; all parameters already set
    call createFileEntry



    .exit:
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret

    .takenError:
        pop ax
        mov si, .takenErrorMsg
        call puts
        jmp .exit
    .takenErrorMsg: db 'Error: Directory already exists!', ENDL, 0

    .dirFullError:
        pop ax
        mov si, .dirFullError
        call puts
        jmp .exit
    .dirFullErrorMsg: db 'Error: Parent directory is full!', ENDL, 0

    .fsFullError:
        pop ax
        mov si, .fsFullError
        call puts
        jmp .exit
    .fsFullErrorMsg: db 'Error: File system is full!', ENDL, 0





; creates an entry in a directory
; param:
; AX: sector of directory to put file entry into
; BX: sector to point to
; SI: pointer to name
createFileEntry:
    pusha

    ; convert sector to memory address
    call getSectorMemoryLocation

    ; check name isnt taken
    mov di, ax  ; DI is used in compareFileNames
    inc di      ; skip the sector num, we are comparing names
    mov cx, 31  ; max 31 entries
    .checkName:
        call compareFileNames   ; compares [SI] & [DI] up to 15 chars
        jc .takenError          ; if equal, the name is taken

        add di, 16  ; skip to next entry
        loop .checkName

    ; search for an empty slot in the directory
    mov di, ax  ; ptr to directory
    mov cx, 31  ; times to loop
    .findEmpty:
        cmp byte [di], 0     ; check if sector number is null
        je .addEntry    ; if so, use that

        add di, 16
        loop .findEmpty
        ; if we get here, the dir was full
        jmp .dirFullError


    ; pointer to empty file entry in DI
    ; sector ptr in BX from args
    .addEntry:
        mov byte [di], bl   ; save the sector ptr
        inc di

        mov cx, 15          ; copy 15 chars
        .copyChar:
            mov byte al, [si]
            mov byte [di], al

            inc si
            inc di
            loop .copyChar

    .exit:
        popa
        ret

    .takenError:
        pop ax
        mov si, .takenErrorMsg
        call puts
        jmp .exit
    .takenErrorMsg: db 'Error: Name is taken!', ENDL, 0

    .dirFullError:
        pop ax
        mov si, .dirFullError
        call puts
        jmp .exit
    .dirFullErrorMsg: db 'Error: Directory is full!', ENDL, 0