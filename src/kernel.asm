org 0x7e00
bits 16

%define ENDL 0x0D, 0x0A



;
; MEMORY LOCATION DEFNITIONS
;
%define WORKING_DIRECTORY_INFO  0x0500
%define WORKING_DIRECTORY_NAME  0x0510
%define COMMAND_BUFFER_START    0x0520
%define COMMAND_BUFFER_END      0x05FF

%define OSINFO                  0x8600
%define FILE_SYSTEM_START       0x8800


; CODE BEGIN
jmp signatureSkip           ; jump past signature, must be a short jump, (2 bytes) for signature reader to work
dw 'ZM'                     ;  signature to show that kernel is loaded correctly, 0x5A4D
signatureSkip: jmp kernel   ; jump past dependencies


; DEPENDENCIES
%include "src/lib/stdin.inc"
%include "src/lib/stdout.inc"
%include "src/lib/string.inc"
%include "src/lib/fs.inc"


kernel:
    dw 'AB'
    call clearScreen    ; clears bios message and sets video mode

    mov bl, 01h
    call setColor

    ; print welcome message
    mov si, Loaded ; move pointer to string into source indicator
    call puts

; loop that lets us run a command
; dx stores length of command buffer
; each char is pushed to stack
main:

    call displayPrompt
    


    mov si, COMMAND_BUFFER_START    ; buffer pointer set to 0500h (start of free ram segment)
    xor dx, dx                      ; reset dx (length of buffer)

    ; get keyboard input & print it
    getChar:
        call waitForKey ; wait for a keypress

        ; special keys
        ; backspace
        cmp al, 08h
        je backspaceKey

        ; enter
        cmp al, 0dh
        je enterKey

        defaultKey:
            ; regular key handler
            ; push the ascii code to buffer so we have the command string when enter is pressed
            call putc   ; print the char
            mov [si], ax
            inc si
            inc dx              ; increment length of command buffer
            jmp getChar


        ; special key handlers

        backspaceKey:
            ; if we are at the start of the command, dont do anything
            or dx, dx
            jz getChar

            ; when we putc backspace, it only moves the cursor backward
            call putc   ; move cursor backward


            mov al, ' '     ; write a space in the next spot
            call putc       ; backspace just moved us backward so this removes the prev char
            mov al, 08h
            call putc       ; putc backspace again to move our cursor back
            dec si          ; decrement command pointer
            dec dx          ; decrement length of command buffer
            jmp getChar


        ; if the char is enter, also move to next line
        enterKey:
            call putc   ; move to next line
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

            
            

        ; get command without arguments
        ; SI = command buffer
        ; DI = where to put arg-less command
        ; put it after the command buffer
        ; mov di, si
        ; add di, dx      ; end of command buffer
        ; call getCmd
        

        ; find command and run it
        ; cmpCmd takes DX as arg for how many chars to compare
        ; but DX already holds our string length so no need to modify
        ; FOR NOW ALL COMMANDS ARE IN KERNEL
        ; EVENTUALLY ONCE FILE SYSTEM IS WORKING MOVE THEM ALL TO DISCRETE FILES
        ; 
        ; DI HOLDS COMMAND BY ITSELF
        ; SI HOLDS COMMAND WITH ARGS
        cmdHelpTest:
            mov di, cmdHelpStr
            call cmpCmd
            jc cmdHelp

        cmdExitTest:
            mov di, cmdExitStr
            call cmpCmd
            jc cmdExit

        cmdRebootTest:
            mov di, cmdRebootStr
            call cmpCmd
            jc cmdReboot

        cmdEchoTest:
            mov di, cmdEchoStr
            call cmpCmd
            jc cmdEcho

        cmdClearTest:
            mov di, cmdClearStr
            call cmpCmd
            jc cmdClear

        cmdColorTest:
            mov di, cmdColorStr
            call cmpCmd
            jc cmdColor

        cmdTestTest:
            mov di, cmdTestStr
            call cmpCmd
            jc cmdTest
            

        ; mov bl, [cmdHelpStr] ; test where SI points to by writing to it
        ; mov [si], bl

        ; mov bl, dl ; test where SI points to by writing to it
        ; add bl, '0'
        ; mov [si], bl

        noCommandFound:
            ; do not display cmd not found msg if command length is 0 (it is always incremented to hold null character)
            cmp dx, 1
            je main

            ; else, if no command was found, display message and jump to start
            ; 'Command "${command}" could not be found'
            push si
            mov si, CommandNotFound1
            call puts
            pop si

            call puts

            mov si, CommandNotFound2
            call puts

            jmp main



; COMMANDS:
cmdHelp:
%include "src/apps/help.asm"
cmdExit:
%include "src/apps/exit.asm"
cmdReboot:
%include "src/apps/reboot.asm"
cmdEcho:
%include "src/apps/echo.asm"
cmdClear:
%include "src/apps/clear.asm"
cmdColor:
%include "src/apps/color.asm"
cmdTest:
%include "src/apps/test.asm"



; --FUNCTIONS--
displayPrompt:
    ; [USERNAME]@[HOSTNAME]:[PATH][SYMBOL]
    mov si, Username
    call puts

    mov al, '@'
    call putc

    mov si, Hostname
    call puts

    mov al, ':'
    call putc

    mov si, WORKING_DIRECTORY_NAME
    call puts

    mov si, Symbol
    call puts

    ret



; OS INFO (REPLACE LATER INTO OSINFO SECTOR
; user will then be able to change on first startup
; and later we can add commands that let them change it later
Hostname: db 'simpleOS', 0
Username: db 'zimbobub', 0
; working directory stored in RAM
Symbol: db '/$ ', 0


; messages
Loaded: db 'Kernel loaded', ENDL, 'Type "help" for a list of commands to get started', ENDL, 0


; errors
CommandNotFound1: db 'Command "', 0
CommandNotFound2: db '" could not be found', ENDL, 0


; commands
cmdHelpStr: db 'help', 0
cmdExitStr: db 'exit', 0
cmdRebootStr: db 'reboot', 0
cmdEchoStr: db 'echo', 0
cmdClearStr: db 'clear', 0
cmdColorStr: db 'color', 0
cmdTestStr: db 'test', 0


; command data
helpMsg: db ENDL, '    help   : displays this message', ENDL, '    exit   : shuts down the computer', ENDL, '    reboot : restarts the os', ENDL, '    echo   : prints what you input it', ENDL, '    clear  : clears the screen', ENDL, '    color  : sets colors', ENDL, ENDL, 0


; gives us 2kb of space to write both kernel and programs
; if this is changed, change the sectors read number in bootloader to ((kernelSize / 512) + 1)
times 2048 - ($-$$) db 0
