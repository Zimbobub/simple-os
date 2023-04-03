; clear
; clears the screen

; clear screen, also resets color so we need to set it again
call clearScreen

; set color
push bx

mov bl, 01h     ; eventually load the user's preferred color
call setColor

pop bx

jmp main