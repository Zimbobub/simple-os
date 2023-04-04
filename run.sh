

# gdb build/os.bin
qemu-system-i386 -hda build/os.bin -monitor stdio
# sendkey ctrl-alt-delete



<<comment
to read code segment (bootloader first 512, kernel next 2048)
memsave 31744 2560 "/home/zimbobub/Desktop/coding/osdev/clios/.memdump"
to read data segment 1
memsave 1280 30464 "/home/zimbobub/Desktop/coding/osdev/clios/.memdump"
comment