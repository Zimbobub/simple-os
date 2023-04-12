; test
; does whatever we need to for testing features

pusha



; test mkdir
add si, 5
mov ax, [WORKING_DIRECTORY_INFO]
call createDirectory


popa
jmp main
