BRICKID=$1
cp track_realign.rootrc track.rootrc
makescanset -set=$BRICKID.0.0.0 -dz=-1350 -from_plate=57 -to_plate=1 -dzbase=195
emtra -set=$BRICKID.0.0.0 -v=2 -new > out/tracking_realign.txt