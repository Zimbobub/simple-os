org 0x7e00
bits 16

jmp kernel
db 0xAA  ; signature to show that kernel was loaded


%define ENDL 0x0D, 0x0A



%include "src/output.inc"


kernel:
    
    call clearScreen    ; clears bios message and sets video mode

    mov bl, 01h
    call setColor


    ; mov al, 'T'
    ; call putc

    ; print hello world
    mov si, Loaded ; move pointer to string into source indicator
    call puts

; loop that lets us run a command
; dx stores length of command buffer
; each char is pushed to stack
main:

    ; eventually create a pwd function that is called here

    mov al, '>'
    call putc


    mov si, 0500h   ; buffer pointer set to 0500h (start of free ram segment)
    xor dx, dx      ; reset dx (length of buffer)

    ; get keyboard input & print it
    getChar:
        ; get char
        xor ah, ah ; reset ah to 0
        int 16h

        ; loop again if no char
        or al, al
        jz getChar

        ; print char
        call putc



        ; special key detectors

        ; backspace
        cmp al, 08h
        je backspaceKey

        ; enter
        cmp al, 0dh
        je enterKey


        ; regular key handler
        ; push the ascii code to buffer so we have the command string when enter is pressed
        mov [si], ax
        inc si
        inc dx              ; increment length of command buffer
        jmp getChar


        ; special key handlers

        ; when we putc backspace, it only moves the cursor backward
        backspaceKey:
            mov al, ' '     ; write a space in the next spot
            call putc       ; backspace just moved us backward so this removes the prev char
            mov al, 08h
            call putc       ; putc backspace again to move our cursor back
            dec si          ; decrement command pointer
            dec dx          ; decrement length of command buffer
            jmp getChar


        ; if the char is enter, also move to next line
        enterKey:
            ; add a newline as enter key only does carriage return
            mov al, 0ah
            call putc

            ; command buffer stuff & print command out for debugging purposes
            ; move si to start of command
            xor ax, ax      ; zero ah and al
            mov [si], ax    ; move 0 to last char
            inc dx


            sub si, dx      ; subtract length from pointer so it points to start
            inc si          ; SI = (SI - (DX - 1))
            ;call puts      ; TEMPORARY: print back command to check that the command buffer is working

            ; mov bl, [cmdHelpStr] ; test where SI points to by writing to it
            ; mov [si], bl

            ; print newline as well
            ; mov al, 0dh
            ; call putc

            
            
        ; find command and run it
        ; cmpStr takes DX as arg for how many chars to compare
        ; but DX already holds our string length so no need to modify
        ; FOR NOW ALL COMMANDS ARE IN KERNEL
        ; EVENTUALLY ONCE FILE SYSTEM IS WORKING MOVE THEM ALL TO DISCRETE FILES

        

        cmdHelpTest:
            mov di, cmdHelpStr
            call cmpStr
            je cmdHelp

        cmdExitTest:
            mov di, cmdExitStr
            call cmpStr
            je cmdExit

        cmdRebootTest:
            mov di, cmdRebootStr
            call cmpStr
            je cmdReboot
            

        ; mov bl, [cmdHelpStr] ; test where SI points to by writing to it
        ; mov [si], bl

        ; mov bl, dl ; test where SI points to by writing to it
        ; add bl, '0'
        ; mov [si], bl

        noCommandFound:
            ; if no command was found, display message and jump to start
            ; 'Command "${command}" could not be found'
            push si
            mov si, CommandNotFound1
            call puts
            pop si

            call puts

            mov si, CommandNotFound2
            call puts

            jmp main





; --FUNCTIONS--


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



; COMMANDS:


; help
; lists all commands
cmdHelp:
    ; eventually allow it to look up help page for specific commands
    mov si, helpMsg
    call puts
    jmp main



; exit
; clears screen & halts cpu
cmdExit:
    call clearScreen
    mov bl, 00h
    call setColor
    cli
    hlt
    ; no need to jump back to main


; reboot
; restarts the os
cmdReboot:
    jmp 0FFFFh:0        ; jump to beginning of BIOS, should reboot


; echo
; implement later once args are working
cmdEcho:
    



; kernel data
Loaded: db 'Kernel loaded', ENDL, 'Type "help" for a list of commands to get started', ENDL, 0
CommandNotFound1: db 'Command "', 0
CommandNotFound2: db '" could not be found', ENDL, 0


; commands
cmdHelpStr: db 'help', 0
cmdExitStr: db 'exit', 0
cmdRebootStr: db 'reboot', 0


; command data
helpMsg: db ENDL, '    help   : displays this message', ENDL, '    exit   : shuts down the computer', ENDL, '    reboot : restarts the os', ENDL, ENDL, 0


; gives us 2kb of space to write both kernel and programs
; if this is changed, change the sectors read number in bootloader to ((kernelSize / 512) + 1)
times 2048 - ($-$$) db 0
