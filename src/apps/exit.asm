; exit
; clears screen & halts cpu
call clearScreen
mov bl, 00h
call setColor
cli
hlt
; no need to jump back to main