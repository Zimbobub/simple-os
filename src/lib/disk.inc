

;
; Converts an LBA address to a CHS address
; Parameters:
;   - ax: LBA address
; Returns:
;   - cx [bits 0-5]: sector number
;   - cx [bits 6-15]: cylinder
;   - dh: head
;
LBAtoCHS:

    push ax
    push dx

    xor dx, dx                          ; dx = 0
    div word [18]                       ; ax =  LBA / SectorsPerTrack
                                        ; dx = LBA % SectorsPerTrack

    inc dx                              ; dx = (LBA % SectorsPerTrack + 1) = sector
    mov cx, dx                          ; cx = sector

    xor dx, dx                          ; dx = 0
    div word [2]                        ; ax = (LBA / SectorsPerTrack) / Heads = cylinder
                                        ; dx = (LBA / SectorsPerTrack) % Heads = head
    mov dh, dl                          ; dh = head
    mov ch, al                          ; ch = cylinder (lower 8 bits)
    shl ah, 6
    or cl, ah                           ; put upper 2 bits of cylinder in CL

    pop ax
    mov dl, al                          ; restore DL
    pop ax
    ret







;
; Reads sectors from a disk
; Parameters:
;   - ax: LBA address
;   - cl: number of sectors to read (up to 128)
;   - dl: drive number
;   - es:bx: memory address where to store read data
;
; http://www.ctyme.com/intr/rb-0607.htm
diskRead:

    push ax                             ; save registers we will modify
    push bx
    push cx
    push dx
    push di

    push cx                             ; temporarily save CL (number of sectors to read)
    call LBAtoCHS                       ; compute CHS
    pop ax                              ; AL = number of sectors to read
    
    mov ah, 02h
    mov di, 3                           ; retry count

.retry:
    pusha                               ; save all registers, we don't know what bios modifies
    stc                                 ; set carry flag, some BIOS'es don't set it
    int 13h                             ; carry flag cleared = success
    jnc .done                           ; jump if carry not set

    ; read failed
    popa
    call diskReset

    dec di
    test di, di
    jnz .retry

.fail:
    ; all attempts are exhausted
    jmp .readError

.done:
    popa
.exit:
    pop di
    pop dx
    pop cx
    pop bx
    pop ax                             ; restore registers modified
    ret

.readError:
    mov si, .errormsg
    call puts
    jmp .exit
.errormsg: db 'boot error: failed to load kernel from floppy disk after 3 attempts', ENDL, 0






;
; Resets disk controller
; Parameters:
;   dl: drive number
;
diskReset:
    pusha
    mov ah, 0
    stc
    int 13h
    jc floppyError2
.exit:
    popa
    ret
.resetError:
    mov si, .errormsg
    call puts
    jmp .exit
.errormsg: db 'boot error: failed to reset floppy disk', ENDL, 0






; Error messages
