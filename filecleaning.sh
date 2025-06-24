#!/bin/sh
BRICKID=$1
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
BRICKPATH="/eos/experiment/sndlhc/emulsionData/2022/emureco_Napoli/RUN1/b000121/cells"
for CELL in $(seq 0 323); do
    xcell=$((CELL % 18 + 1))
    ycell=$((CELL / 18 + 1))
    folder=$BRICKPATH/cell_${xcell}0_${ycell}0/$BRICKFOLDER
    echo "launching rm -I $folder/p*/*.*.*.*.raw.root"
    rm -I $folder/p*/*.*.*.*.raw.root
done