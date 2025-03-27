BRICKID=$1
mkdir out_tag
seq 1 56 | xargs -i -P 15 bash -c 'echo tagalign '$BRICKID'.{}.0.0 && . ./tagalignplate.sh '$BRICKID' {} > out_tag/'$BRICKID'.{}.0.0.tal.txt'
makescanset -set=$BRICKID.100.0.0 -dz=-1350 -from_plate=57 -to_plate=1 -dzbase=195
tagtra -set=$BRICKID.100.0.0 -v=2
