#!/bin/bash

BRICKID=$1
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
CELL=$2
xcell=$((CELL % 18 + 1))
ycell=$((CELL / 18 + 1))
folder=cell_${xcell}0_${ycell}0/$BRICKFOLDER
file_aff=AFF.$CELL.tar.gz

if [ -f "$folder/$file_aff" ]; then
    cd "$folder"
    tar -xzf "$file_aff"
else
    echo "$file_aff is missing" >> missing_files_$CELL.log
fi