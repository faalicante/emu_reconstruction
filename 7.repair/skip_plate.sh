BRICKID=$1
PLATENUMBER=$2
PLATEFOLDER="$(printf "p%03d" $(( 10#$PLATENUMBER )))"
PLATETOALIGN=$((PLATENUMBER-1))

mv $PLATEFOLDER $PLATEFOLDER.bad

source scanset.sh $BRICKID
cp align_1.rootrc align.rootrc
source alignplate.sh $BRICKID $PLATETOALIGN 2

source scanset.sh $BRICKID
cp align_2.rootrc align.rootrc
source alignplate.sh $BRICKID $PLATETOALIGN 2
source scanset.sh $BRICKID
cp align_3.rootrc align.rootrc
source alignplate.sh $BRICKID $PLATETOALIGN 2