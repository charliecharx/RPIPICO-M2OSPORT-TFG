#!/usr/bin/env bash

filetoexecute=$1
#Check if folder build exists in current directory
if [ -d "build" ]; then
    echo "---->Build folder exists"
else
    echo "---->Build folder does not exist"
    mkdir build
fi
#Change to build directory
cd build
#Export path to pico-sdk (absolute path)
export PICO_SDK_PATH=/home/prrtchr/pico/pico-sdk
#Preconfigure cmake and make
cmake ..
make -j6

echo "---->Project built"

echo "---->moving generated files to the build subdirectory"
#For each .bin, .dis, .elf, .hex, .uf2 and .elf.map file in build directory, move it to the directory of the same name without the extension
#This can be changed later.
for file in *.bin *.dis *.elf *.hex *.uf2 *.elf.map; do
    if [ -f "$file" ]; then
        mv "$file" "${file%.*}"
    fi
done

#Check if the user inserted a file to execute
if [ -z "$filetoexecute" ]; then
    echo "---->No file to execute. Build finished"
    exit 1
fi

echo "---->Detecting mounted RPIPico"
#Check if rpipico is mounted
if [ -d "/media/$(whoami)/RPI-RP2" ]; then
    echo "---->RPI-RP2 mounted. Attempting to copy file"
    cd ..

    #Copy the file to the mounted drive
    sudo cp "./build/${filetoexecute}.uf2" "/media/$(whoami)/RPI-RP2/${filetoexecute}.uf2"
    sudo sync
    sudo umount "/media/$(whoami)/RPI-RP2"
    echo "---->File: $filetoexecute copied to RPIPico. Build finished"
    exit 1
else
    echo "---->RPIPico not mounted. Build finished"
    exit 1
fi
