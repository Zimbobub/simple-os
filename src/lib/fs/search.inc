; functions for file system that find a file/folder


; gets the name of a folder from its sector number
; returns nothing if we ask for sector 10 (root)
;
; params:
; AX: sector number
; DI: pointer to where to put name
; NOTE: allow at least 16 bytes for name to fit into
getDirectoryNameBySector:
    ; save regs
    push ax
    push bx
    push cx
    push si

    ; check if we are in root folder (byte 0 will be 0x0A)
    ; if so, we dont need to write a name as root dir doesnt have one
    cmp al, 0x0A
    je .rootDir

    ; save the sector number
    mov cx, ax

    ; convert our sector number to memory address
    call getSectorMemoryLocation

    ; read the first byte (sector #) of the first entry (parent dir)
    ; simplifies to 'mov ax, [ax]' , but we cant do that
    mov bx, ax
    mov ax, [bx]

    ; get the memory address of the parent directory
    call getSectorMemoryLocation   ; sector pointer to parent dir is alr in AX
    
    ; search the directory
    mov si, ax                      ; pointer to directory we will search
    mov bx, cx                      ; sector entry we are looking for
    call searchDirectoryForSector   ; search for folder with that sector

    ; get the name and write it to DI
    mov si, ax              ; move ax to si as AX cannot be a pointer
    mov cx, 15              ; loop 15 times (15 char maximum length)
    .writeCharToMemory:
        inc si              ; inc char pointer (loop starts pointing to byte before the string)
        mov byte bl, [si]   ; get the character from memory
        mov byte [di], bl   ; save that to [DI]
        inc di              ; increment end of string pointer
        loop .writeCharToMemory
    jmp .end

    .rootDir:
        mov bl, 0
        mov cx, 15
        .clearDirChar:
            mov byte [di], bl   ; move 0 into [DI]
            inc di              ; increment pointer
            loop .clearDirChar  ; loop 15 times

    .end:
        pop si
        pop cx
        pop bx
        pop ax
        ret






; finds the sector number of a file/dir from its name
; params:
; BX: sector # to search through
; SI: pointer to name string    (must be null terminated)
; returns:
; AX: sector # we found (0 if not found)
findSectorByName:
    push bx
    push cx
    push si
    push di

    ; get to the specified dir
    mov ax, bx
    call getSectorMemoryLocation
    mov di, ax
    inc di

    ; AX: sector number of current file entry
    ; DI: pointer to (name of) file entry we are searching

    ; loop 32 entries
    mov cx, 32
    .loop:
        ; takes SI & DI as args & compares them (up to 15 chars, or null termination)
        ; carry flag set if equal
        call compareFileNames
        jc .found

        add ax, 16  ; jump to next file entry sector #
        add di, 16  ; jump to next file entry name
        loop .loop

    .notFound:
        xor ax, ax
        jmp .exit

    .found:
        ; cannot directly move [AX] to AX
        mov bx, ax
        xor ah, ah
        mov al, [bx]
        jmp .exit

    .exit:
        pop di
        pop si
        pop cx
        pop bx
        ret






; loops over every entry in a dir to find a sector
; params:
; SI: pointer to directory we are searching through
; BX: sector number to find
; returns:
; AX: pointer to that file entry
searchDirectoryForSector:
    push cx
    push si

    mov cx, 32  ; max 32 file entries in folder
    .loop:
        cmp byte [si], bl    ; compare file entry sector # to one we want
        je .exit             ; if found, exit

        add si, 16      ; inc ax by 16, moving to next file entry
        loop .loop      ; decrement cx until loop ends

    ; if we didnt find it
    .notFound:
        xor si, si  ; zero the pointer, as we return it

    .exit:
        mov ax, si

        pop si
        pop cx
        ret





