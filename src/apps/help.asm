; help
; lists all commands
; eventually allow it to look up help page for specific commands

mov si, helpMsg
call puts


jmp main

helpMsg: db '  help   : displays this message', ENDL, \
            '  exit   : shuts down the computer', ENDL, \
            '  reboot : restarts the OS', ENDL, \
            '  echo   : prints what you input it', ENDL, \
            '  clear  : clears the screen', ENDL, \
            '  color  : sets the background color', ENDL, \
            '  cs     : changes the working sector', ENDL, \
            '  cd     : changes the working directory', ENDL, \
            '  ls     : lists all files in the working directory', ENDL, 0
