BRICKID=$1
mkdir -p report/tal/
mkdir out_tag
makescanset -set=$BRICKID.0.0.0 -dz=-1350 -from_plate=57 -to_plate=1 -dzbase=195
seq 1 56 | xargs -i -P 15 bash -c 'echo tagalign '$BRICKID'.{}.0.0 && . ./tagalignplate.sh '$BRICKID' {} 1'
seq 1 56 | xargs -i -P 15 bash -c 'echo tagalign '$BRICKID'.{}.0.0 && . ./tagalignplate.sh '$BRICKID' {} 2'
seq 1 56 | xargs -i -P 15 bash -c 'echo tagalign '$BRICKID'.{}.0.0 && . ./tagalignplate.sh '$BRICKID' {} 3'
makescanset -set=$BRICKID.0.0.0 -dz=-1350 -from_plate=57 -to_plate=1 -dzbase=195
seq 1 56 | xargs -i -P 15 bash -c 'echo tagalign '$BRICKID'.{}.0.0 && . ./tagalignplate.sh '$BRICKID' {} 1 > out_tag/'$BRICKID'.{}.0.0.tal1.txt'
seq 1 56 | xargs -i -P 15 bash -c 'echo tagalign '$BRICKID'.{}.0.0 && . ./tagalignplate.sh '$BRICKID' {} 2 > out_tag/'$BRICKID'.{}.0.0.tal2.txt'
seq 1 56 | xargs -i -P 15 bash -c 'echo tagalign '$BRICKID'.{}.0.0 && . ./tagalignplate.sh '$BRICKID' {} 3 > out_tag/'$BRICKID'.{}.0.0.tal3.txt'
