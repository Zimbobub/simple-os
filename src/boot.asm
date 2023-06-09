; definition of KERNEL_SIZE is put here at compile time
; KERNEL_SIZE = size of kernel in segments + 1 (for bootsegment)
org 0x7c00
bits 16
%define ENDL 0x0D, 0x0A

; %define KERNEL_SIGNATURE 0x5A4D
%define KERNEL_SIGNATURE 'ZM'


jmp _start


_start:
    ; show loading message
    mov si, Loading
    call puts


    ; setup data segments
    mov ax, 0           ; can't set ds/es directly
    mov ds, ax
    mov es, ax
    mov ss, ax
    
    ; setup stack
    mov ss, ax
    mov sp, 0x7C00              ; stack grows downwards from where we are loaded in memory

    ; some BIOSes might start us at 07C0:0000 instead of 0000:7C00, 
    ; make sure we are in the expected location
    push es
    push word .after    ; push location of rest of bootloader to stack
    retf                ; returning jumps to the popped address


.after:

readKernel:
    ; LBA adress
    mov ax, 1024
    ; sectors to read 
    xor ch, ch
    mov cl, 127     ; read 127 sectors (max we can, entire os will fit here cos im lazy)
    ; drive num
    xor dh, dh
    mov dl, 80h

    ; location in memory to write to
    mov bx, KERNEL_LOAD_SEGMENT
    mov es, bx
    mov bx, KERNEL_LOAD_OFFSET

    ; read kernel
    call diskRead



checkKernelSignature:
    mov bx, KERNEL_LOAD_OFFSET

    add bx, 514                 ; add 512 to shift over 1 segment, add 2 to skip the initial jump instruction
    mov ax, [bx]                ; move the signature from loaded segment to cx

    cmp ax, KERNEL_SIGNATURE    ; compare segment's signature to expected
    jne kernelSignatureError



; as the kernel is loaded right after the bootloader in memory
; we can jump to the end of the file to jump to the kernel
jmp kernelStart


; if we somehow escape main, reboot so we dont start executing random functions
jmp reboot
























; print char
; assume ascii value is in reg AL
putc:
    ; save modified regs
    push ax
    push bx

    mov ah, 0eh
    mov bh, 00h
    mov bl, 07h
    ; call interrupt
    int 10h

    ; restore regs
    pop bx
    pop ax

    ret





; loops over putc to print a string
; assume that string starting pointer is in register SI
puts:
    ; save ax
    push ax

    ; label to fetch next char of string
    .nextChar:
        mov al, [si]    ; read from memory address pointed to by SI (stack pointer)
        inc si          ; increment stack pointer

        or al, al       ; check if AL is 0 (end of string)
        jz .exit     ; if so jump to end

        call putc       ; else print char
        jmp .nextChar    ; and loop over
    
    .exit:
        ; restore ax
        pop ax
        ret

















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

kernelSignatureError:
    mov si, ErrorSignature
    jmp throwError

floppyError:
    mov si, ErrorFloppy1
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
Loading: db 'Loading kernel...', ENDL, 0
RebootMessage: db 'Press any key to reboot', 0

; Error messages
ErrorSignature: db 'boot error: incorrect kernel signature', ENDL, 0
ErrorFloppy1: db 'boot error: failed to load kernel from floppy disk after 3 attempts', ENDL, 0
ErrorFloppy2: db 'boot error: failed to reset floppy disk', ENDL, 0

; load at 7c00 as for some reason we can only read from index 0
KERNEL_LOAD_SEGMENT     equ 0000h
KERNEL_LOAD_OFFSET      equ 7c00h


; fill rest of boot sector with 0s & note the sector as bootable
times 510 - ($-$$) db 0
dw 0xAA55



; non bootsector part of bootloader
; %include "src/bootExtended.inc"

kernelStart: