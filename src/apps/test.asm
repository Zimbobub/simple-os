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
; push ax
; push cx
; push si

; mov si, 0x8E00      ; location of tmp.bin in fs
; mov cx, 512

; TESTLOOP:
;     mov al, [si]
;     call printU8Hex
;     mov al, ' '
;     call putc

;     ; increment pointer
;     inc si

;     ; print newline if % 16
;     mov ax, si
;     and ax, 0b0000000000001111  ; mask to last 4 bits
;     or ax, ax                   ; check last 4 bits are 0
;     jz .printNewline            ; if so, print newline
;     .printNewlineReturn:
;     loop TESTLOOP
;     jmp .exit

;     .printNewline:
;         mov al, 0x0D
;         call putc
;         mov al, 0x0A
;         call putc
;         jmp .printNewlineReturn

;     .exit:
;         pop ax
;         pop cx
;         pop si


; push ax

; mov ax, 7
; call setWorkingDirectory

; pop ax


; mov si, msg
; mov cx, 10
; call putsLen

; call newline


pusha




jmp main


file1: db 'asdfasdfasdfasd', 0
file2: db 'asdfasdfasdfasdf', 0

; msg: db 'testmsg'