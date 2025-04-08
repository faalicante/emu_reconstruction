#!/bin/bash

BRICKID=$1
BRICKFOLDER=$(printf "b%06d" $BRICKID)
CELL=$2
xcell=$((CELL % 18 + 1))
ycell=$((CELL / 18 + 1))
folder=cell_${xcell}0_${ycell}0/$BRICKFOLDER
counter_local=0

echo "rocessing cell $CELL"

for p in $(seq 1 57); do
    plate=$(printf "p%03d" $p)
    base="$folder/$plate/$BRICKID.$p.$xcell.$ycell"
    file_mos="${base}.mos.root"
    file_cp="${base}.cp.root"
    file_cp_frag="${base}.0.cp.root"
    dest_base="$folder/$plate/$BRICKID.$p.0.0"

    if [ -f "$file_cp" ]; then
        mv "$file_mos" "$dest_base.mos.root" 2>/dev/null
        mv "$file_cp" "$dest_base.cp.root" 2>/dev/null
        rm -f "$file_cp_frag"
    else
        echo "$file_cp is missing" >> missing_cp_cell_$CELL.log
        ((counter_local++))
    fi
done

echo "Finished cell $CELL with $counter_local missing plates"
