

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
        mov al, [si]    ; read from memory address pointed to by SI (stack pointer)
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








; char in al
; count in cx
; 80 in cx = entire row
printTimes:
    .loop:
        call putc
        loop .loop
    ret




clearScreen:
    ; clears screen by setting video mode
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
    