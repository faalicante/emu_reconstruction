#!/bin/bash

BRICKID=$1
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"

for CELL in $(seq 0 323); do
    xcell=$((CELL % 18 + 1))
    ycell=$((CELL / 18 + 1))
    folder=cell_${xcell}0_${ycell}0/$BRICKFOLDER

    for p in $(seq 1 57); do
        plate=$(printf "p%03d" $p)
        base="$folder/$plate/$BRICKFOLDER.$p.$xcell.$ycell"
        file_mos="${base}.mos.root"
        file_cp="${base}.cp.root"
        dest_base="$folder/$plate/$BRICKFOLDER.$p.0.0"

        if [ -f "$file_cp" ]; then
            mv "$file_mos" "$dest_base.mos.root" 2>/dev/null
            mv "$file_cp" "$dest_base.cp.root" 2>/dev/null
        else
            echo "$p, $CELL -- $file_cp is missing"
        fi
    done
done