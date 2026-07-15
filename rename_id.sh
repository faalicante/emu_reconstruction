#!/bin/sh
BRICKID1=21
BRICKID2=121
BRICKFOLDER1="$(printf "b%0*d" 6 $BRICKID1)"
BRICKFOLDER2="$(printf "b%0*d" 6 $BRICKID2)"
BRICKPATH="/eos/experiment/sndlhc/emulsionData/emureco_Napoli/RUN1/b000121/cells"
for CELL in $(seq 0 323); do
    xcell=$((CELL % 18 + 1))
    ycell=$((CELL / 18 + 1))
    folder=$BRICKPATH/cell_${xcell}0_${ycell}0/$BRICKFOLDER1
    if [ ! -d "$folder" ]; then
        echo "Folder $folder does not exist, skipping..."
        continue
    fi
    echo $folder
    cd $folder
    makescanset -set=$BRICKID2.0.0.0 -copyset -A=$BRICKID1.0.0.0
    rm ../$BRICKFOLDER2/p0*/*par
    for p in $(seq 1 57); do
        plate="$(printf "p%03d" $p)" 
        mv $plate/$BRICKID1.$p.0.0.raw.root ../$BRICKFOLDER2/$plate/$BRICKID2.$p.0.0.raw.root
        mv $plate/$BRICKID1.$p.0.0.mos.root ../$BRICKFOLDER2/$plate/$BRICKID2.$p.0.0.mos.root
        mv $plate/$BRICKID1.$p.0.0.cp.root ../$BRICKFOLDER2/$plate/$BRICKID2.$p.0.0.cp.root
    done
    mv $BRICKFOLDER1.0.0.0.trk.root ../$BRICKFOLDER2/$BRICKFOLDER2.0.0.0.trk.root
    mv $BRICKFOLDER1.0.0.0.vtx.root ../$BRICKFOLDER2/$BRICKFOLDER2.0.0.0.vtx.root
    mv $BRICKFOLDER1.0.0.0.vtx.discimp.root ../$BRICKFOLDER2/$BRICKFOLDER2.0.0.0.vtx.discimp.root
    mv $BRICKFOLDER1.0.0.0.vtx.refit.root ../$BRICKFOLDER2/$BRICKFOLDER2.0.0.0.vtx.refit.root
    mv unbend.root ../$BRICKFOLDER2/unbend.root
    rm *save.rootrc
    mv *.rootrc ../$BRICKFOLDER2/
    mv *.sh ../$BRICKFOLDER2/
    cd ../
    rm -r $BRICKFOLDER1
done