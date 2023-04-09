

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

    ; save the sector number
    mov cx, ax

    ; convert our sector number to memory address
    call getSectorMemoryLocation

    ; move the parent dir # to ax (currently pointed to by ax)
    ; to do this we need to have both of these in diff regs
    mov bx, ax
    mov ax, [bx]

    ; check if we are in root folder (byte 0 will be 0x06)
    ; if so, we dont need to write a name as root dir doesnt have one
    cmp ax, 0x06
    je .end
    
    ; otherwise:
    ; open parent folder (pointed to by '..', first entry)
    ; NOTE: first byte of an entry is sector number, last 15 are name
    
    

    ; search for folder with that sector (make a seperate func)
    ; get the name and write it to SI

    .end:
        ; temp for debugging:
        mov byte [di], 'E'

        ; restore regs
        pop cx
        pop bx
        pop ax
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





