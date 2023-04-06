



mkdir -p build                      # make build folder if it doesnt exist


# mount fs
# printf %"$COLUMNS"s |tr " " "-"
echo "Mounting file system:"

rm -rf build/mount                  # delete old mount folder
mkdir -p build/mount                # make new one
node ./mount.js                     # run mount script

# combine the files to one binary
cd build/mount/                     # move to mount folder cos the cat | ls | sort doesnt work otherwise
cat `ls | sort -g` > ../fs.bin      # concatenate each binary, sorted numerically
cd ../..                            # return to main project dir

# printf %"$COLUMNS"s |tr " " "-"
# newline separator
echo -e





# create system prefs/info sector (empty for now)
echo "Creating system info sector..."
dd if=/dev/zero of=build/info.bin bs=512 count=1 &> /dev/null    # silence output

echo "Building kernel..."
nasm -f bin -o build/kernel.bin src/kernel.asm                  # build kernel first





# get the size of the OS binary:
echo "Getting OS size..."

# method to dynamically create os size definition: 
# https://stackoverflow.com/questions/40895165/nasm-provide-constant-value-at-compile-time
cat build/kernel.bin build/info.bin build/fs.bin > build/tmp.bin # concat all of the binaries to one file

OS_Size=`stat --printf="%s" build/tmp.bin`                      # get the kernel's size in bytes
OS_Size=$(expr $OS_Size + 1023)                                 # +512 so that we add one to the final total (for bootloader) & +511 to round up
OS_Size=$(expr $OS_Size / 512)                                  # divide OS_Size by 512 to get num of sectors





echo "Building bootloader..."

rm -f build/boot.asm                                            # delete old temp bootloader file
printf "%%define KERNEL_SIZE %s\n" $OS_Size > build/boot.asm    # put the definition of the kernel into temp file
cat src/boot.asm >> build/boot.asm                              # concat the full asm file on top of the definition
nasm -f bin -o build/boot.bin build/boot.asm                    # compile the concatenated file





# concat the compiled bootloader into the OS
cat build/boot.bin build/tmp.bin > build/os.bin
echo "Build complete"
echo -e











# do optional stuff (keep temp files, split final binary to sectors...)
# FLAGS:
# -c - prevents cleanup of temp files
# -f - prevents cleanup of mount folder
# -s - creates a folder of split binaries for each sector
#

# set defaults
cleanupTmp=true
cleanupMnt=true
splitFiles=false

# get flags
while getopts 'cfs' OPTION; do
  case "$OPTION" in
    c)  cleanupTmp=false;;
    f)  cleanupMnt=false;;
    s)  splitFiles=true;;
    ?)  echo "script usage: $(basename \$0) [-c] [-f] [-s]";;
  esac
done
shift "$(($OPTIND -1))"

# cleanup temp files
if $cleanupTmp; then
    echo "Cleaning up build directory, to skip this step, use -c"

    cd build                    # move into build so rm command is simpler
    ls | grep -xv -e "os.bin" -e "mount" | parallel rm -v
    cd ..
    echo -e
fi

# cleanup mount folder
if $cleanupMnt; then
    echo "Removing mount directory, to skip this step, use -f"
    rm -rv build/mount
    echo -e
fi

if $splitFiles; then
    echo "Creating split sector files"
    
    rm -f build/splitSectors/*      # delete everything if it alr exists
    mkdir -p build/splitSectors     # create folder if not exist
    cd build/splitSectors

    # create files of 512 bytes, named numerically, with suffix of '.bin'
    split --bytes=512 --numeric-suffixes --additional-suffix=.bin --verbose ../os.bin "" # <-- empty prefix instead of 'x'

    cd ../..    # return to original folder

    echo -e
fi





echo "Done!"



# notes:
# bootloader:   0x0000-0x01FF
# kernel:       0x0200-0x09FF
# sysinfo:      0x0A00-0x0BFF
# file system:  0x0C00...
