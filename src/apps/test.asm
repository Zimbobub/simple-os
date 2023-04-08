; test
; does whatever we need to for testing features


; test print hex
; push bx

; mov bl, 0x42
; call printU8Hex

; pop bx



; test mouse
; http://www.ctyme.com/intr/rb-1596.htm enable
; http://www.ctyme.com/intr/rb-1601.htm init
; push ax
; push bx

; mov ax, 0xC205
; mov bh, 01h
; int 15h

; ; ah is status return
; mov bl, ah
; call printU8Hex

; pop bx
; pop ax


; test fs
push ax
push cx
push si

mov si, 0x8E00      ; location of tmp.bin in fs
mov cx, 512

TESTLOOP:
    mov al, [si]
    call putc
    inc si
    loop TESTLOOP

pop ax
pop cx
pop si

jmp main
