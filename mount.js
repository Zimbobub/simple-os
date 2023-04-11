const fs = require('fs');
const path = require('path');

// path we are currently mounting
let directoryPath = path.join(__dirname, 'mount');

// fs starts at sector 10
// increment with every file/folder we mount
let sectorNum = 10;

// create OSINFO buffer, first 6 bytes are empty, the rest we will concatenate
let fsInfo = [];


mountFolder('mount', 10, 10);      // for simplicity & one less edge case, the root folder's parent dir is itself

// osinfoAddFile(10, true, false, 12);
osinfoCreate();






function mountFolder(name, sector, parentDirSector) {
    // console.log(`Mounting dir  at sector ${sector}:`.padEnd(27), path.relative(__dirname, directoryPath));

    // create fsinfo entry
    osinfoAddFile(sector, false, false, fs.readdirSync(directoryPath).length + 1);

    // save sectorNum before it is modified
    const mySector = sector;

    // create empty buffer
    let directoryData = Buffer.alloc(0);
    // parent folder entry
    directoryData = Buffer.concat([directoryData, createFileEntry('..', parentDirSector)]);

    // read folder
    const fileList = fs.readdirSync(directoryPath);

    // have to use regular for loop cos we modify the items
    for (let i = 0; i < fileList.length; i++) {
        // create fileEntryBuffer of 8 bytes
        sectorNum++;
        directoryData = Buffer.concat([directoryData, createFileEntry(fileList[i], sectorNum)]); 6

        // save the already calucated 'isDirectory' for later & other stuff
        fileList[i] = {
            name: fileList[i],
            isDir: fs.statSync(path.join(directoryPath, fileList[i])).isDirectory(),
            sector: sectorNum,
        };
    }



    // pad it to 512 bytes, and check it doesnt go above
    directoryData = Buffer.concat([directoryData], 512);
    if (directoryData.length > 512) { throw new Error(`Error: ${file} is too big!`) }

    // write binary to /build/mount/${sectorNum}
    fs.writeFileSync(path.join(__dirname, 'build/mount', mySector.toString()), directoryData);



    // recursively call this function or mountFile() for each entry
    fileList.forEach(file => {
        // check if it is a directory or not
        if (file.isDir) {

            // push the new dir to the directory path
            directoryPath = path.join(directoryPath, file.name);
            // recursively call function
            mountFolder(file.name, file.sector, mySector);
            // pop that directory from the path once we return
            directoryPath = path.dirname(directoryPath);

        } else {

            mountFile(file.name, file.sector);

        }
    });

}







function createFileEntry(name, sector) {
    const entrySize = 16;

    // check file name length isnt too big
    if (name.length > (entrySize - 1)) throw new Error(`Error: file "${name}"'s name is too long! File names can be max 15 characters.`);

    // create array
    let arr = [sector];
    // push each char to the array
    for (const char of name) { arr.push(char.charCodeAt()); }
    // create buffer, and pad it to 16 bytes if it is not already
    // from: https://stackoverflow.com/questions/69114003/pad-nodejs-buffer-to-32-bytes-after-creation-from-string
    let buffer = Buffer.from(arr);
    buffer = Buffer.concat([buffer], entrySize);

    // console.log(arr);
    // console.log(`${name}: `.padStart(6), buffer);

    return buffer;
}







function mountFile(name, sector) {
    // console.log(`Mounting file at sector ${sector}:`.padEnd(27), path.relative(__dirname, path.join(directoryPath, name)));

    // create fsinfo entry
    osinfoAddFile(sector, false, false, 0);

    // read the file
    let fileData = fs.readFileSync(path.join(directoryPath, name))

    // convert it to a buffer
    fileData = Buffer.from(fileData);

    // pad it to 512 bytes
    fileData = Buffer.concat([fileData], 512);

    // check it isnt too big
    if (fileData.length > 512) { throw new Error(`Error: ${name} is too big!`) }

    // write it to build mount folder
    fs.writeFileSync(path.join(__dirname, 'build/mount', sector.toString()), fileData);
}







// OSINFO sector

// bits:
//     0: is used
//     1: is executable
//     2: is protected ( all system files are protected, reads/writes require password )
//     3: folder entries #
//     4: folder entries #
//     5: folder entries #
//     6: folder entries #
//     7: folder entries #
// the file is a folder if the number of entries > 0

function osinfoAddFile(sector, executable, protected, entries) {
    // check entries is below 5 bits
    if (entries >= 31) throw new Error(`Error: directories cannot have more than 31 entries!`);

    // combine all the flags and stuff
    let info = (
        0b10000000 +                                // is used, if we are creating this, it will always be used
        (executable ? 0b00100000 : 0b00000000) +    // is exec, folders cannot be executed
        (protected ? 0b00100000 : 0b00000000) +     // is protected, arg passed in func
        entries                                     // number of entries, already confirmed to be 5 bit addressable (if a file, entries=0)
    );
    // console.log(info.toString(2));

    // turn it into a buffer
    let buffer = Buffer.alloc(1);
    buffer.writeUInt8(info)
    // console.log(buffer);

    // add it to fsinfo, we dont push it because sectors are sometimes mounted out of order
    fsInfo[sector] = buffer;
}




function osinfoCreate() {
    // console.log(fsInfo);
    osInfoBuf = Buffer.alloc(0);    // alloc empty buffer

    // loop over fsinfo array and concat them all
    for (let i = 0; i < fsInfo.length; i++) {
        if (!fsInfo[i]) {
            osInfoBuf = Buffer.concat([osInfoBuf, Buffer.alloc(1)]);    // concat an empty byte to the buffer
            continue;
        }
        osInfoBuf = Buffer.concat([osInfoBuf, fsInfo[i]]);
    }

    osInfoBuf = Buffer.concat([osInfoBuf], 512);    // pad it to 512 bytes

    // console.log(osInfoBuf);
    fs.writeFileSync(path.join(__dirname, 'build/info.bin'), osInfoBuf);

}
