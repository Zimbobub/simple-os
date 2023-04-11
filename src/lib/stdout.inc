

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
    ; save regs
    push ax
    push si

    ; label to fetch next char of string
    .nextChar:
        mov byte al, [si]    ; read from memory address pointed to by SI (stack pointer)
        inc si          ; increment stack pointer

        or al, al       ; check if AL is 0 (end of string)
        jz .exit     ; if so jump to end

        call putc       ; else print char
        jmp .nextChar    ; and loop over
    
    .exit:
        ; restore regs
        pop si
        pop ax
        ret





; prints a string of set length
; assume that string starting pointer is in register SI
; length is in CX
putsLen:
    ; save regs
    push ax
    push cx
    push si

    ; label to fetch next char of string
    .nextChar:
        mov byte al, [si]    ; read from memory address pointed to by SI (stack pointer)
        call putc       ; else print char
        inc si          ; increment stack pointer
        loop .nextChar  ; and loop over
    
    .exit:
        ; restore regs
        pop si
        pop cx
        pop ax
        ret





; print unsigned 8 bit register as binary number
; value in AL
; internal vars:
; ah: nothing
; al: input, then char to print
; bh: countdown (from 8)
; bl: saved input
printU8Binary:
    ; save regs
    push ax
    push bx

    ; count down from 8
    mov bh, 8
    mov bl, al  ; mov input into bl
    .loop:
        test bl, 0b10000000 ; just check for uppermost bit
        jnz .print1         ; if so, print a 1
                            ; else, print a 0
        .print0:
            mov al, '0'
            call putc
            jmp .next
        .print1:
            mov al, '1'
            call putc
            jmp .next
        
        .next:
            shl bl, 1   ; shift across so we test the next bit
            dec bh      ; decrement countdown
            or bh, bh
            jnz .loop   ; if coundown not 0, jump to top

    ; restore regs
    pop bx
    pop ax
    ret





; print a 16 bit binary number
; input in AX
printU16Binary:
    push ax         ; save AX before we modify
    mov al, ah      ; move AH into AL (arg for printU8Hex)
    call printU8Binary ; call for upper byte
    pop ax          ; restore AL
    call printU8Binary ; call for lower byte
    ret





; print 8 bit hexadecimal number
; value in AL
; internal vars:
; ah: nothing
; al: input, then upper 4 bits
; bh: nothing
; bl: then lower 4 bits
printU8Hex:
    ; save regs
    push ax
    push bx
    push si

    ; set regs up
    ; NOTE: we need to use 16 bit registers as we are adding them to SI later on
    xor ah, ah          ; clear BH just in case
    mov bx, ax          ; move first hex char to al, and second to bl
    shr al, 4           ; shift bh reg over so we only have upper 4 bits
    and bl, 0b00001111  ; apply mask to bl so we only have lower 4 bits
    
    ; MAIN PART OF CODE
    call .printHexChar
    mov ax, bx
    call .printHexChar
    jmp .exit
    
    ; expects the char in AL (AH EMPTY)
    .printHexChar:
        mov si, .hexString  ; move pointer to list of hex chars to SI
        add si, ax          ; add the value to the pointer, making it point to the char we want
        mov al, [si]        ; move the character it points to into AL, we dont need AX anymore so we can modify it
        call putc           ; print the char
        ret                 ; return
    
    .exit:
        pop si
        pop bx
        pop ax
        ret

    .hexString: db '0123456789ABCDEF'





; print a 16 bit hex number
; input in AX
printU16Hex:
    push ax         ; save AX before we modify
    mov al, ah      ; move AH into AL (arg for printU8Hex)
    call printU8Hex ; call for upper byte
    pop ax          ; restore AL
    call printU8Hex ; call for lower byte
    ret





; prints a newline
newline:
    push ax

    mov al, 0x0D
    call putc
    mov al, 0x0A
    call putc

    pop ax
    ret





; char in al
; count in cx
; 80 in cx = entire row
printTimes:
    .loop:
        call putc
        loop .loop
    ret





; clears screen by setting video mode
clearScreen:
    push ax
    
    xor ah, ah
    mov al, 03h
    int 10h

    pop ax
    ret





; http://www.ctyme.com/intr/rb-0101.htm
; takes bl as arg of what color to set screen to
setColor:
    push ax
    push bx

    mov ah, 0bh
    xor bh, bh
    ; mov bl, 01h
    int 10h
    
    pop bx
    pop ax
    ret
