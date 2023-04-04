const fs = require('fs');
const path = require('path');

const directoryPath = path.join(__dirname, 'mnt');

// fs starts at sector 7
// increment with every file/folder we mount
let sectorNum = 7;




mountFolder('mnt', 7);      // for simplicity & one less edge case, the root folder's parent dir is itself

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
                children.push({ name: file, dir: stats.isDirectory() })
            });
        });
    });

    // compile that array to a binary
    // write binary to /build/mount/${sectorNum}
    // increment sectorNum
    // recursively call this function or mountFile() for each entry
    // return
}

function mountFile(name) {

}
