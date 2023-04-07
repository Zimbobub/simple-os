
# optional stuff (keep temp files, split final binary to sectors...)
# FLAGS:
# -h - shows help message
# -c - prevents cleanup of temp files
# -f - prevents cleanup of mount folder
# -s - creates a folder of split binaries for each sector
#

# set defaults
cleanupTmp=true
cleanupMnt=true
splitFiles=false

# get flags
while getopts 'hcfs' OPTION; do
    case "$OPTION" in
        h)  printf "SIMPLE-OS BUILD TOOL \n -h : show this help script \n -c : skip build directory cleanup \n -f : skip build mount directory cleanup \n -s : create a folder with each disk sector its own file (useful for debugging) \n"; exit 1;;
        c)  cleanupTmp=false;;
        f)  cleanupMnt=false;;
        s)  splitFiles=true;;
        ?)  echo "script usage: $(basename \$0) [-c] [-f] [-s]";;
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



# concat the compiled bootloader into the OS
cat build/boot.bin \
    build/kernel.bin \
    build/info.bin \
    build/fs.bin \
    > build/os.bin
echo "Build complete"
echo -e








#===================================================================#
#                               DEBUG                               #
#===================================================================#
# cleanup temp files
if $cleanupTmp; then
    echo "Cleaning up build directory, to skip this step, use -c"

    cd build                    # move into build so rm command is simpler
    ls | grep -xv -e "os.bin" -e "mount" | parallel rm -rv
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
    split \
        --bytes=512 \
        --numeric-suffixes \
        --suffix-length=3 \
        --additional-suffix=.bin \
        --verbose \
        ../os.bin \
        "" # <-- empty prefix instead of 'x'

    cd ../..    # return to original folder

    echo -e
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
