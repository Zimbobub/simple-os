



mkdir -p build                      # make build folder if it doesnt exist


# mount fs
rm -r build/mount                   # delete old mount folder
mkdir -p build/mount                # make new one
node ./mount.js                     # run mount script








# build bootloader and kernel

# method to dynamically create kernel size definition: 
# https://stackoverflow.com/questions/40895165/nasm-provide-constant-value-at-compile-time

nasm -f bin -o build/kernel.bin src/kernel.asm                  # build kernel first
kernelSize=`stat --printf="%s" build/kernel.bin`                # get the kernel's size in bytes
kernelSize=$(expr $kernelSize + 1023)                           # +512 so that we add one to the final total & +511 to round up
kernelSize=$(expr $kernelSize / 512)                            # divide kernelSize by 512 to get num of sectors


rm build/tmp                                                    # delete old tmp file
printf "%%define KERNEL_SIZE %s\n" $kernelSize > build/tmp      # put the definition of the kernel into tmp file
cat src/boot.asm >> build/tmp                                   # concatenate the full asm file on top of the definition
nasm -f bin -o build/boot.bin build/tmp                         # compile the concatenated file


cat build/boot.bin build/kernel.bin > build/os.bin              # concat all of the binaries to one file

