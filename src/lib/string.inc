
;
; compare string
; compares until hits a null char in either string
; params:
; SI: pointer to string1
; DI: pointer to string2
; returns:
; carry flag set if strings match
;
; NOTE: we check if either is null first, so we are checking if one string starts with the other
; (eg: "test" == "testing")
;
cmpStr:
    ; save modified regs
    push ax
    push si
    push di
    cmpChar:
        ; check if either pointer points to null char
        mov al, [di]
        or al, al
        jz .isEqual

        mov al, [si]    ; need to move [si] to a register as we cannot compare two bytes from memory
        or al, al
        jz .isEqual

        ; compare they are equal
        cmp al, [di]
        jne .notEqual

        ; increment pointers
        inc si
        inc di

        ; otherwise continue to exit
    .isEqual:
        stc     ; set carry flag
        jmp .exit
    .notEqual:
        clc     ; clear carry flag

    .exit:
        ; restore regs
        pop di
        pop si
        pop ax
        ret









;
; compare string of length
; continues for set length
; params:
; SI: pointer to string1
; DI: pointer to string2
; DX: chars to check
; returns:
; carry flag set if strings match
;
cmpStrLen:
    ; save modified regs
    push ax
    push dx
    push si
    push di
    .cmpChar:
        mov al, [si]    ; need to move [si] to a register as we cannot compare two bytes from memory
        cmp al, [di]
        jne .notEqual
        ; increment pointers & decrement countdown
        inc si
        inc di
        dec dx
        ; jump if we havent counted to zero yet
        or dx, dx
        jnz .cmpChar
        ; otherwise continue to exit
    .isEqual:
        stc     ; set carry flag
        jmp .exit
    .notEqual:
        clc     ; clear carry flag

    .exit:
        ; restore regs
        pop di
        pop si
        pop dx
        pop ax
        ret







;
; compare command
; modified cmpStr to exit when we hit a spacebar
; params:
; SI: pointer to string1
; DI: pointer to string2
; DX: chars to check
; returns:
; carry flag set if strings match
;
cmpCmd:
    ; save modified regs
    push ax
    push dx
    push si
    push di
    .cmpChar:
        ; need to move [si] to a register as we cannot compare two bytes from memory
        mov al, [si]

        ; check if we hit a spacebar, if so, exit with success
        cmp al, ' '
        je .isEqual

        ; compare the two chars
        cmp al, [di]
        jne .notEqual

        ; increment pointers & decrement countdown
        inc si
        inc di
        dec dx
        ; jump if we havent counted to zero yet
        or dx, dx
        jnz .cmpChar
        ; otherwise continue to exit with success
    .isEqual:
        stc     ; set carry flag
        jmp .exit
    .notEqual:
        clc     ; clear carry flag

    .exit:
        ; restore regs
        pop di
        pop si
        pop dx
        pop ax
        ret












; ;
; ; get command
; ; returns the command entered, without the arguments
; ; params:
; ; SI: pointer to command
; ; DI: pointer to where to put command
; ;
; getCmd:
;     ; save regs
;     push ax
;     push si
;     push di

;     .loop:
;         ; read char from memory
;         mov ax, [si]

;         ; exit if null char
;         or ax, ax       
;         jz .end

;         ; exit if spacebar
;         cmp ax, ' '     
;         je .end

;         ; otehrwise, push it to new string
;         mov [di], ax

;         ; increment pointers
;         inc si
;         inc di

;         ; loop again
;         jmp .loop

;     .end:
;         ; add null char to end
;         inc di
;         xor ax, ax
;         mov [di], ax
        
;         ; restore regs & exit
;         pop di
;         pop si
;         pop ax
;         ret


