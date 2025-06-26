#!/bin/bash

BRICKID=$1
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
for CELL in $(seq 1 323); do
	xcell=$((CELL % 18 + 1))
	ycell=$((CELL / 18 + 1))
	folder=cell_${xcell}0_${ycell}0/$BRICKFOLDER/AFF
	for p in $(seq 1 56); do
		base=$BRICKID.$((p+1)).0.0_$BRICKID.$p
		file_aff=$base.$xcell.$ycell.aff.par
		if [ -f "$folder/$file_aff" ]; then
   		    mv $folder/$file_aff $folder/$base.0.0.aff.par
		    mv $folder/$base.$xcell.$ycell.al.root $folder/$base.0.0.al.root
        else
            echo "$p, $CELL"
        fi
    done
done