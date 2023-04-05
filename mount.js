const fs = require('fs');
const path = require('path');

// path to root of mount
const mountRoot = path.join(__dirname, 'mnt');
// path we are currently mounting
let directoryPath = path.join(__dirname, 'mnt');

// fs starts at sector 6
// increment with every file/folder we mount
let sectorNum = 6;



mountFolder('mnt', 6);      // for simplicity & one less edge case, the root folder's parent dir is itself







function mountFolder(name, sector, parentDirSector) {
    console.log(`Mounting dir  at sector ${sector}:`.padEnd(27), path.relative(__dirname, directoryPath));


    // save sectorNum before it is modified
    const mySector = sector;

    // create empty buffer
    let directoryData = Buffer.alloc(0);
    // parent folder entry
    directoryData = Buffer.concat([directoryData, createFileEntry('..', true, parentDirSector)]);

    // read folder
    const fileList = fs.readdirSync(directoryPath);

    // have to use regular for loop cos we modify the items
    for (let i = 0; i < fileList.length; i++) {
        // create fileEntryBuffer of 8 bytes
        sectorNum++;
        let stats = fs.statSync(path.join(directoryPath, fileList[i]))
        directoryData = Buffer.concat([directoryData, createFileEntry(fileList[i], stats.isDirectory(), sectorNum)]); 6

        // save the already calucated 'isDirectory' for later & other stuff
        fileList[i] = {
            name: fileList[i],
            isDir: stats.isDirectory(),
            sector: sectorNum
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







function createFileEntry(name, dir, sector) {
    const entrySize = 16;

    // check file name length isnt too big
    if (name.length > (entrySize - 2)) throw new Error(`Error: file "${name}"'s name is too long!`);

    // flags
    let flags = 0b00000000;
    if (dir == true) flags += 0b10000000;  // add 'isDir' flag if the file is a directory

    // create array
    let arr = [flags, sector]
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
    console.log(`Mounting file at sector ${sector}:`.padEnd(27), path.relative(__dirname, path.join(directoryPath, name)));

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



