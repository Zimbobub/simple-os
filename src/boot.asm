org 0x7c00
bits 16
%define ENDL 0x0D, 0x0A

jmp _start

%include "src/output.inc"
; %include "src/disk.inc"

_start:
    mov si, Loading
    call puts

    ; read extended bootloader
    ; location on disk
    mov ax, 512     ; LBA adress

    xor ch, ch
    mov cl, 1       ; sectors to read

    xor dh, dh
    mov dl, 80h     ; drive num


    ; location in memory
    mov bx, KERNEL_LOAD_SEGMENT
    mov es, bx
    mov bx, KERNEL_LOAD_OFFSET

    call diskRead


    call bootTest
    
    ; call KERNEL_LOAD_SEGMENT:KERNEL_LOAD_OFFSET


    call clearScreen    ; clears bios message and sets video mode

    ; set colour
    ; http://www.ctyme.com/intr/rb-0101.htm
    ; mov ah, 0bh
    ; xor bh, bh
    ; mov bl, 01h
    ; int 10h





    ; print hello world
    mov si, Welcome ; move pointer to string into stack pointer
    call puts

; loop that lets us run a command
; dx stores length of command buffer
; each char is pushed to stack
main:

    ; eventually create a pwd function that is called here

    mov al, '>'
    call putc


    xor si, si      ; reset si
    xor dx, dx      ; reset dx

    ; get keyboard input & print it
    getChar:
        ; get char
        xor ah, ah ; reset ah to 0
        int 16h

        ; loop again if no char
        or al, al
        jz getChar

        ; print char
        call putc



        ; special key detectors

        ; backspace
        cmp al, 08h
        je backspaceKey

        ; enter
        cmp al, 0dh
        je enterKey


        ; regular key handler
        ; push the ascii code to stack so we have the command string when enter is pressed
        mov [si], ax
        inc si
        inc dx              ; increment length of command buffer
        jmp getChar


        ; special key handlers

        ; when we putc backspace, it only moves the cursor backward
        backspaceKey:
            mov al, ' '     ; write a space in the next spot
            call putc       ; backspace just moved us backward so this removes the prev char
            mov al, 08h
            call putc       ; putc backspace again to move our cursor back
            dec si          ; decrement command pointer
            dec dx          ; decrement length of command buffer
            jmp getChar


        ; if the char is enter, also move to next line
        enterKey:
            ; add a newline as enter key only does carriage return
            mov al, 0ah
            call putc

            ; command buffer stuff & print command out for debugging purposes
            ; move si to start of command
            xor ah, ah
            mov [si], ax    ; move 0 to last char
            sub si, dx      ; subtract length from pointer so it points to start
            call puts
            ; newline as well
            mov al, 0dh
            call putc
            

            jmp main


; if we somehow escape main reboot so we dont start executing random functions
jmp reboot






















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
    call LBAtoCHS                     ; compute CHS
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
    jmp floppyError

.done:
    popa

    pop di
    pop dx
    pop cx
    pop bx
    pop ax                             ; restore registers modified
    ret







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
    
    popa
    ret




; error messages

floppyError:
    mov si, ErrorFloppy
    jmp throwError

floppyError2:
    mov si, ErrorFloppy2
    jmp throwError


; expects error message in SI
throwError:
    call puts
reboot:
    mov si, RebootMessage
    call puts

    mov ah, 0
    int 16h                     ; wait for keypress
    jmp 0FFFFh:0                ; jump to beginning of BIOS, should reboot








; data
Loading: db 'Loading...', ENDL, 0
Welcome: db 'Welcome to the most useful OS ever', ENDL, 0
RebootMessage: db 'Press key to reboot', 0

; Error messages
ErrorFloppy: db 'err: disk read failed after 3 tries', ENDL, 0
ErrorFloppy2: db 'err: disk reset failed', ENDL, 0

KERNEL_LOAD_SEGMENT     equ 0x2000
KERNEL_LOAD_OFFSET      equ 0


; fill rest of boot sector with 0s & note the sector as bootable
times 510 - ($-$$) db 0
dw 0xAA55



; non bootsector part of bootloader
%include "src/bootExtended.inc"
