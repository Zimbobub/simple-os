
# optional stuff (keep temp files, split final binary to sectors...)
# FLAGS:
# -h - shows help message
# -c - prevents cleanup of temp files
# -f - prevents cleanup of mount folder
# -s - creates a folder of split binaries for each sector
#

# set defaults
# verbose=false
cleanup=true
splitFiles=false
run=false

# get flags
while getopts 'hcsr' OPTION; do
    case "$OPTION" in
        h)  printf "SIMPLE-OS BUILD TOOL \n \
                    -h : show this help message \n \
                    -c : skip build directory cleanup \n \
                    -s : create a folder with each disk sector its own file (useful for debugging) \n \
                    -r : run qemu once done"; exit 1;;
        v)  verbose=true;;
        c)  cleanupTmp=false;;
        s)  splitFiles=true;;
        r)  run=true;;
        ?)  echo "run './build.sh -h' for a list of options";;
    esac
done
shift "$(($OPTIND -1))"







#===================================================================#
#                               BUILD                               #
#===================================================================#
# make build folder if it doesnt exist
mkdir -p build



echo "Building bootloader..."
nasm -f bin -o build/boot.bin src/boot.asm



echo "Building kernel..."
nasm -f bin -o build/kernel.bin src/kernel.asm



# create system prefs/info sector (empty for now)
# this is now built in mount.js
# echo "Creating system info sector..."
# dd if=/dev/zero of=build/info.bin bs=1 count=512 &> /dev/null    # silence output



# printf %"$COLUMNS"s |tr " " "-"
echo "Mounting file system..."

rm -rf build/mount                  # delete old mount folder
mkdir -p build/mount                # make new one
node ./mount.js                     # run mount script

# combine the files to one binary
cd build/mount/                     # move to mount folder cos the cat | ls | sort doesnt work otherwise
cat `ls | sort -g` > ../fs.bin      # concatenate each binary, sorted numerically
cd ../..                            # return to main project dir

# printf %"$COLUMNS"s |tr " " "-"
# newline separator
# echo -e



# concat the compiled bootloader into the OS
cat build/boot.bin \
    build/kernel.bin \
    build/info.bin \
    build/fs.bin \
    > build/os.bin
echo "Build complete, finishing up..."
# echo -e








#===================================================================#
#                               DEBUG                               #
#===================================================================#
# cleanup temp files
if $cleanupTmp; then
    echo "Cleaning up build directory, to skip this step, use -c"

    cd build                    # move into build so rm command is simpler
    ls | grep -xv -e "os.bin" | parallel rm -r
    cd ..
    # echo -e
fi

if $splitFiles; then
    echo "Creating split sector files"
    
    rm -f build/splitSectors/*      # delete everything if it alr exists
    mkdir -p build/splitSectors     # create folder if not exist
    cd build/splitSectors

    # create files of 512 bytes, named numerically, with suffix of '.bin'
    split \
        --bytes=512 \
        --numeric-suffixes \
        --suffix-length=3 \
        --additional-suffix=.bin \
        ../os.bin \
        "" # <-- empty prefix instead of 'x'

    cd ../..    # return to original folder

    # echo -e
fi





#===================================================================#
#                              FINISH                               #
#===================================================================#
# check binary isnt over 127 sectors
if [ -n "$(find "build/os.bin" -prune -size 65024)" ]; then
    echo "Error: OS binary is too big!"
    exit 1
fi
# otherwise pad it to 127 sectors
truncate --size=65024 build/os.bin



echo "Done!"



# notes:
# bootloader:   0x0000-0x01FF
# kernel:       0x0200-0x09FF
# sysinfo:      0x0A00-0x0BFF
# file system:  0x0C00-0xFDFF





# AUTO RUN
if $run; then
    # echo -e
    printf %"$COLUMNS"s |tr " " "-"
    # echo -e
    # echo -e

    qemu-system-i386 -hda build/os.bin -monitor stdio
fi

<<comment

dump (pretty much) all memory (BIOS debugging ig)
pmemsave 0 0xFFFFF "./.memdump.bin"

to read code segment (bootloader first 512, kernel next 4096)
pmemsave 0x7C00 4068 "./.memdump.bin"

to read osinfo segment
pmemsave 0x8E00 0x200 "./.memdump.bin"

to read fs
pmemsave 0x9000 0xEA00 "./.memdump.bin"

to read code, sysinfo & fs (all disk contents)
pmemsave 0x7C00 0xFE00 "./.memdump.bin"

to read data segment 1
pmemsave 0x0500 0x7700 "./.memdump.bin"

comment