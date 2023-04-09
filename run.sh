

# gdb build/os.bin
qemu-system-i386 -hda build/os.bin -monitor stdio
# sendkey ctrl-alt-delete



<<comment

dump (pretty much) all memory (BIOS debugging ig)
pmemsave 0 0xFFFFF "./.memdump.bin"

to read code segment (bootloader first 512, kernel next 2048)
pmemsave 0x7C00 2560 "./.memdump.bin"

to read code, sysinfo & fs
pmemsave 0x7C00 0xFDFF "./.memdump.bin"

to read data segment 1
pmemsave 0x0500 0x7700 "./.memdump.bin"

comment