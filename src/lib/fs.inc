

; sets the working directory based on sector number
; sets the info in the OSINFO sector up

; params:
; AX: sector number

; NOTES:
; 0x0500 - 0x050F ( 16 bytes): info on current dir 
;     0x500 sector #
;     0x501 # of entries
;     0x502 is protected?
; 0x0510 - 0x051F ( 16 bytes): name of current directory

setWorkingDirectory:
    ; save regs
    push ax
    push bx
    push cx
    push di

    ; CODE

    ; SET THE WORKING DIRECTORY NAME
    mov di, WORKING_DIRECTORY_NAME
    call getDirectoryNameBySector

    ; SET THE WORKING DIRECTORY INFORMATION
    ; save the sector #
    mov bx, WORKING_DIRECTORY_INFO
    mov [bx], ax

    ; get info from OSINFO sector
    call getSectorInfo  ; gets sector info about sector[AX], puts it into AX
    
    ; get '# of entries'
    mov cl, al          ; move copy of info to CL
    and cl, 0b0001111   ; mask the last 5 bits (# of entries)
    ; save it
    inc bx
    mov [bx], cl

    ; get 'is protected?'
    mov ch, al          ; move copy of info to CH
    shr ch, 5           ; shift 'is protected' bit down to the lowest bit
    and ch, 0b00000001  ; mask all bits except lowest
    ; save it
    inc bx
    mov [bx], ch

    
    ; restore regs
    pop di
    pop cx
    pop bx
    pop ax
    ret





; gets the name of a folder from its sector number
; returns nothing if we ask for sector 6 (root)
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

    ; check if we are in root folder (byte 0 will be 0x06)
    ; if so, we dont need to write a name as root dir doesnt have one
    cmp al, 0x06
    je .end

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
                                    
    call printU16Hex



    ; get the name and write it to DI
    mov si, ax              ; move ax to si as AX cannot be a pointer
    mov cx, 15              ; loop 15 times (15 char maximum length)
    .writeCharToMemory:
        inc si              ; inc char pointer (loop starts pointing to byte before the string)
        mov byte bl, [si]   ; get the character from memory
        mov byte [di], bl   ; save that to [DI]
        inc di              ; increment end of string pointer
        loop .writeCharToMemory

    .end:
        ; temp for debugging:
        ; mov byte [di], 'E'

        ; restore regs
        pop si
        pop cx
        pop bx
        pop ax
        ret





; NOTE!!!!!!!!!!!: change to 'mov byte ax, [bx]' later so we only read one byte not 2

; reads from OSINFO sector with specified sector
; params:
; AX - sector to get info about
; returns:
; AX - sector info
getSectorInfo:
    push bx

    mov bx, OSINFO  ; move address of OSINFO sector to bx
    add bx, ax      ; add the offset (sector to read from) to pointer
    
    mov byte al, [bx]   ;read from memory address pointed to by bx
    xor ah, ah          ; clear AH as we dont need it

    pop bx
    ret





; converts a sector number to a memory address
; in:  AX: sector num
; out: AX: memory address
getSectorMemoryLocation:
    ; address = 0x7C00 + (sector * 512)
    ; save bx
    push bx

    ; sector * 512
    mov bx, 512
    mul bx      ; returns value into AX
    ; + 0x7C00
    add ax, 0x7C00

    ; exit
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