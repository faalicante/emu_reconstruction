BRICKID=$1
echo "tracking realign $BRICKID.0.0.0"
cp track_realign.rootrc track.rootrc
makescanset -set=$BRICKID.0.0.0 -dz=-1350 -from_plate=57 -to_plate=1 -dzbase=195
emtra -set=$BRICKID.0.0.0 -v=2 -new
echo "tracking 1 $BRICKID.0.0.0"
cp track_unbend.rootrc track.rootrc
emtra -set=$BRICKID.0.0.0 -v=2 -new
echo "unbend 1 $BRICKID.0.0.0"
emunbend -set=$BRICKID.0.0.0 -v=2 -corraff
echo "tracking 2 $BRICKID.0.0.0"
emtra -set=$BRICKID.0.0.0 -v=2 -new
echo "unbend 2 $BRICKID.0.0.0"
emunbend -set=$BRICKID.0.0.0 -v=2 -alg5g -corraff
echo "tracking 3 $BRICKID.0.0.0"
emtra -set=$BRICKID.0.0.0 -v=2 -new
echo "unbend 3 $BRICKID.0.0.0"
emunbend -set=$BRICKID.0.0.0 -v=2 -corraff
echo "tracking 4 $BRICKID.0.0.0"
cp track_dosh.rootrc track.rootrc
emtra -set=$BRICKID.0.0.0 -v=2 -new
echo "unbend 4 $BRICKID.0.0.0"
cp unbend_tree.rootrc unbend.rootrc
emunbend -set=$BRICKID.0.0.0 -v=2 -alg5g
