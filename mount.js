const fs = require('fs');
const path = require('path');

const directoryPath = path.join(__dirname, 'mnt');

// fs starts at sector 7
// increment with every file/folder we mount
let sectorNum = 7;


createFileEntry({ name: "test", dir: true });

// mountFolder('mnt', 7);      // for simplicity & one less edge case, the root folder's parent dir is itself

function mountFolder(name, parentDirSector) {
    // array of subdirectories and files
    let children = [];

    // read folder & create array of entries for each subdir and file
    fs.readdir(directoryPath, function (err, files) {
        // handling error
        if (err) return console.log('Unable to scan directory: ' + err);

        // listing all files using forEach
        files.forEach(function (file) {
            // check if a directory or file
            fs.stat(path.join(directoryPath, file), (err, stats) => {
                children.push({ name: file, dir: stats.isDirectory() });
            });
        });
    });

    // compile that array to a binary
    // pad it to 512 bytes, and check it doesnt go above
    // write binary to /build/mount/${sectorNum}
    // increment sectorNum
    // recursively call this function or mountFile() for each entry
    // return
}

function createFileEntry(file) {
    // check file name length isnt too big
    if (file.name.length > 6) throw new Error(`Error: file "${file.name}"'s name is too long!`);

    // flags
    let flags = 0b00000000;
    if (file.dir == true) flags += 0b10000000;  // add 'isDir' flag if the file is a directory
    // sector pointer
    let sectorPtr = 0xFF;

    // create array
    let arr = [flags, sectorPtr]
    for (const char of file.name) { arr.push(char.charCodeAt()); }
    // create buffer, and pad it to 8 bytes if it is not already
    // from: https://stackoverflow.com/questions/69114003/pad-nodejs-buffer-to-32-bytes-after-creation-from-string
    let buffer = Buffer.from(arr);
    buffer = Buffer.concat([buffer], 8);

    // console.log(arr);
    // console.log(buffer);

    return buffer;
}

function mountFile(name) {

}
