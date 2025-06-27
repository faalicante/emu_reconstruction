#!/bin/bash

BRICKID=$1
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
for CELL in $(seq 0 323); do
    xcell=$((CELL % 18 + 1))
    ycell=$((CELL / 18 + 1))
    folder=cell_${xcell}0_${ycell}0/$BRICKFOLDER
    base="$folder/$BRICKFOLDER.0.$xcell.$ycell"
    file_set="${base}.set.root"
    file_trk="${base}.trk.root"
    dest_base="$folder/$BRICKFOLDER.0.0.0"

    if [ -f "$file_trk" ]; then
        mv "$file_set" "$dest_base.set.root"
        mv "$file_trk" "$dest_base.trk.root"
    else
        echo "$CELL"
    fi
done