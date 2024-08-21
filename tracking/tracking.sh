BRICKID=$1
makescanset -set=$BRICKID.0.0.0 -dz=-1350 -from_plate=57 -to_plate=1 -dzbase=195
cp track1.rootrc track.rootrc
echo tracking realign
emtra -set=$BRICKID.0.0.0 -new -v=2
echo unbend1
emunbend -set=$BRICKID.0.0.0 -v=2
cp track0.rootrc track.rootrc
echo tracking1
emtra -set=$BRICKID.0.0.0 -v=2
echo unbend2
emunbend -set=$BRICKID.0.0.0 -v=2
echo tracking2
emtra -set=$BRICKID.0.0.0 -v=2