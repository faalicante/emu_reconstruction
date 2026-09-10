#!/bin/sh
BRICKID=$1
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
BRICKPATH="/eos/experiment/sndlhc/emulsionData/emureco_CERN/RUN1/$BRICKFOLDER/cells"
for CELL in $(seq 0 323); do
    xcell=$((CELL % 18 + 1))
    ycell=$((CELL / 18 + 1))
    folder=$BRICKPATH/cell_${xcell}0_${ycell}0/$BRICKFOLDER
    echo $folder
    rm -r $folder/output
    rm -r $folder/error
    rm -r $folder/p*/output
    rm -r $folder/p*/error
    rm $folder/p*/*mos.root
    rm $folder/vertex.rootrc
    rm $folder/align.rootrc
    rm $folder/*.save.rootrc
    rm $folder/proc*.sh
done