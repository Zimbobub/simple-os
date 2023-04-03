; color
; takes 1 argument and sets the background color

; colors:
; 0 black
; 1 blue
; 2 lime
; 3 cyan
; 4 red
; 5 pink
; 6 yellow
; 7 white
; ...


push bx
push dx
push si
push di


add si, 6       ; increment si by 6 to skip over 'color ' in the command, straight to the arg
sub dx, 6       ; decrement buffer length by same amount

; check each color
colorChecks:
.black:
    mov di, black
    call cmpCmd
    jc black1
.blue:
    mov di, blue
    call cmpCmd
    jc blue1
.lime:
    mov di, lime
    call cmpCmd
    jc lime1
.cyan:
    mov di, cyan
    call cmpCmd
    jc cyan1
.red:
    mov di, red
    call cmpCmd
    jc red1
.pink:
    mov di, pink
    call cmpCmd
    jc pink1
.yellow:
    mov di, yellow
    call cmpCmd
    jc yellow1
.white:
    mov di, white
    call cmpCmd
    jc yellow1

.error:
    ; color entered is not on list
    mov si, errorMsg
    call puts
    jmp exit



; HANDLERS:
black1:
    mov bl, 00h
    jmp end
blue1:
    mov bl, 01h
    jmp end
lime1:
    mov bl, 02h
    jmp end
cyan1:
    mov bl, 03h
    jmp end
red1:
    mov bl, 04h
    jmp end
pink1:
    mov bl, 05h
    jmp end
yellow1:
    mov bl, 06h
    jmp end
white1:
    mov bl, 07h
    jmp end

end:
    call setColor

exit:
    pop di
    pop si
    pop dx
    pop bx
    jmp main

; data
errorMsg: db 'Error: incorrect color', ENDL, 0

; colors
black: db 'black', 0
blue: db 'blue', 0
lime: db 'lime', 0
cyan: db 'cyan', 0

red: db 'red', 0
pink: db 'pink', 0
yellow: db 'yellow', 0
white: db 'white', 0

; green: db 'green', 0
; lightBlue: db 'lightblue', 0
; lightGreen: db 'lightgreen', 0

