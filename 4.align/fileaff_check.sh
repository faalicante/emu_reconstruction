#!/bin/bash

BRICKID=$1
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
counter_aff=0
for CELL in $(seq 0 323); do
    xcell=$((CELL % 18 + 1))
    ycell=$((CELL / 18 + 1))
    folder=cell_${xcell}0_${ycell}0/$BRICKFOLDER
    file_aff=AFF.$CELL.tar.gz
    if [ -f "$folder/$file_aff" ]; then
        cd $folder
        tar -xzf $file_aff
        cd ../../
    else
        echo $file_aff is missing
        let counter_aff++
    fi
done
echo "Missing $counter_aff cp files."