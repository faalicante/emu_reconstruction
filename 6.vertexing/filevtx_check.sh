#!/bin/bash

BRICKID=$1
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
counter=0
for CELL in $(seq 0 323); do
    xcell=$((CELL % 18 + 1))
    ycell=$((CELL / 18 + 1))
    folder=cell_${xcell}0_${ycell}0/$BRICKFOLDER
    base="$folder/$BRICKFOLDER.0.$xcell.$ycell"
    file_vtx="${base}.vtx.root"
    file_vtxr="${base}.vtx.refit.root"
    dest_base="$folder/$BRICKFOLDER.0.0.0"

    if [ -f "$file_vtx" ]; then
        mv "$file_vtx" "$dest_base.vtx.root"
        mv "$file_vtxr" "$dest_base.vtx.refit.root"
        ((counter ++))
    fi
done
echo "$counter vtx files"