
waitForKey:
    ; get char
    xor ah, ah ; reset ah to 0
    int 16h

    ; loop again if no char
    or al, al
    jz waitForKey
    ; if char, return
    ret