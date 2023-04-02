
;
; compare string
; params:
; SI: pointer to string1
; DI: pointer to string2
; DX: chars to check
; returns:
; carry flag set if strings match
;
cmpStr:
    ; save modified regs
    push ax
    push dx
    push si
    push di
    cmpChar:
        mov al, [si]    ; need to move [si] to a register as we cannot compare two bytes from memory
        cmp al, [di]
        jne strNotEqual
        ; increment pointers & decrement countdown
        inc si
        inc di
        dec dx
        ; jump if we havent counted to zero yet
        or dx, dx
        jnz cmpChar
        ; otherwise continue to exit
    strIsEqual:
        stc     ; set carry flag
        jmp cmpStrExit
    strNotEqual:
        clc     ; clear carry flag

    cmpStrExit:
        ; restore regs
        pop di
        pop si
        pop dx
        pop ax
        ret