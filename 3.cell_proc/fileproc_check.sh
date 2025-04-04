#!/bin/bash

BRICKID=$1
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
counter_cp=0
for CELL in $(seq 0 323); do
    xcell=$((CELL % 18 + 1))
    ycell=$((CELL / 18 + 1))
    folder=cell_${xcell}0_${ycell}0/$BRICKFOLDER
    for p in $(seq 1 57); do
        plate="$(printf "p%0*d" 3 $p)"
        file_mos=$folder/$plate/$BRICKID.$p.$xcell.$ycell.mos.root
        file_cp=$folder/$plate/$BRICKID.$p.$xcell.$ycell.cp.root
        file_cp_frag=$folder/$plate/$BRICKID.$p.$xcell.$ycell.0.cp.root
        if [ -f "$file_cp" ]; then
            mv $file_mos $folder/$plate/$BRICKID.$p.0.0.mos.root
            mv $file_cp $folder/$plate/$BRICKID.$p.0.0.cp.root
            rm $file_cp_frag
        else
            echo $file_cp is missing
            let counter_cp++
        fi
    done
done
echo "Missing $counter_cp cp files."