; prints info on the current directory
pusha

; name
mov si, .nameLabel
call puts

mov si, WORKING_DIRECTORY_NAME
mov cx, 15
call putsLen
call newline





; sector #
mov si, .sectorLabel
call puts

mov al, [WORKING_DIRECTORY_INFO]
call printU8Hex
call newline





; entries number
mov si, .entriesLabel
call puts

call getSectorInfo  ; sector # already in AL
push ax             ; save for getting protected boolean
and al, 0b00011111
call printU8Hex
pop ax
call newline





; protected
mov si, .protLabel
call puts

and al, 0b00100000
shr al, 5
or al, al
jz .printFalse

.printTrue:
    mov si, trueString
    call puts
    jmp .exit

.printFalse:
    mov si, falseString
    call puts



.exit:
    call newline
    popa
    jmp main





; DATA
.nameLabel:    db 'Name      : ', 0
.sectorLabel:  db 'Sector    : ', 0
.entriesLabel: db 'Entries   : ', 0
.protLabel:    db 'Protected : ', 0

trueString: db 'True', 0
falseString: db 'False', 0
