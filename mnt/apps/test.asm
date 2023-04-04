
push si

mov si, msg
call puts

pop si
jmp main

msg: db 'test message', 0