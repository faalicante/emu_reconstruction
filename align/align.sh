BRICKID=$1
makescanset -set=$BRICKID.0.0.0 -dz=-1350 -from_plate=57 -to_plate=1 -dzbase=195
cp align_2.rootrc align.rootrc
emalign -set=$BRICKID.0.0.0 -new -v=2
cp $BRICKFOLDER.0.0.0.align.pdf plot_second_align/$BRICKFOLDER.0.0.0.secondalign.pdf
makescanset -set=$BRICKID.0.0.0 -dz=-1350 -from_plate=57 -to_plate=1 -dzbase=195
cp align_3.rootrc align.rootrc
emalign -set=$BRICKID.0.0.0 -new -v=2
cp $BRICKFOLDER.0.0.0.align.pdf plot_third_align/$BRICKFOLDER.0.0.0.thirdalign.pdf
makescanset -set=$BRICKID.0.0.0 -dz=-1350 -from_plate=57 -to_plate=1 -dzbase=195