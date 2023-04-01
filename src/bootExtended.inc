bootTest:
    ; set colour
    ; http://www.ctyme.com/intr/rb-0101.htm
    ; mov ah, 0bh
    ; xor bh, bh
    ; mov bl, 01h
    ; int 10h

    mov al, 'G'
    mov ah, 0eh
    mov bh, 00h
    mov bl, 07h
    int 10h


    ret