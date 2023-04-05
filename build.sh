



mkdir -p build                      # make build folder if it doesnt exist


# mount fs
# printf %"$COLUMNS"s |tr " " "-"
echo "Mounting file system:"

rm -r build/mount                   # delete old mount folder
mkdir -p build/mount                # make new one
node ./mount.js                     # run mount script

# combine the files to one binary
cd build/mount/                     # move to mount folder cos the cat | ls | sort doesnt work otherwise
cat `ls | sort -g` > ../fs.bin      # concatenate each binary, sorted numerically
cd ../..                            # return to main project dir

# printf %"$COLUMNS"s |tr " " "-"
echo -e




# build bootloader and kernel

# method to dynamically create kernel size definition: 
# https://stackoverflow.com/questions/40895165/nasm-provide-constant-value-at-compile-time
echo "Building kernel..."

nasm -f bin -o build/kernel.bin src/kernel.asm                  # build kernel first
kernelSize=`stat --printf="%s" build/kernel.bin`                # get the kernel's size in bytes
kernelSize=$(expr $kernelSize + 1023)                           # +512 so that we add one to the final total & +511 to round up
kernelSize=$(expr $kernelSize / 512)                            # divide kernelSize by 512 to get num of sectors


echo "Building bootloader..."

rm build/tmp                                                    # delete old tmp file
printf "%%define KERNEL_SIZE %s\n" $kernelSize > build/tmp      # put the definition of the kernel into tmp file
cat src/boot.asm >> build/tmp                                   # concatenate the full asm file on top of the definition
nasm -f bin -o build/boot.bin build/tmp                         # compile the concatenated file


# create system prefs/info sector (empty for now)
dd if=/dev/zero of=build/info.bin bs=512 count=1 &> /dev/null    # silence output


cat build/boot.bin build/kernel.bin build/info.bin build/fs.bin > build/os.bin # concat all of the binaries to one file

echo "Done"



# notes:
# bootloader:   0x0000-0x01FF
# kernel:       0x0200-0x09FF
# sysinfo:      0x0A00-0x0BFF
# file system:  0x0C00...
