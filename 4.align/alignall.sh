BRICKID=$1
mkdir out_al
makescanset -set=$BRICKID.0.0.0 -dz=-1350 -from_plate=57 -to_plate=1 -dzbase=195
cp first_align.rootrc align.rootrc
seq 1 56 | xargs -i -P 15 bash -c 'echo emalign '$BRICKID'.{}.0.0 && . ./align.sh '$BRICKID' {} > out_al/'$BRICKID'.{}.0.0.al.txt'
makescanset -set=$BRICKID.0.0.0 -dz=-1350 -from_plate=57 -to_plate=1 -dzbase=195
cp second_align.rootrc align.rootrc
seq 1 56 | xargs -i -P 15 bash -c 'echo emalign '$BRICKID'.{}.0.0 && . ./align.sh '$BRICKID' {} > out_al/'$BRICKID'.{}.0.0.al.txt'
makescanset -set=$BRICKID.0.0.0 -dz=-1350 -from_plate=57 -to_plate=1 -dzbase=195
cp third_align.rootrc align.rootrc
seq 1 56 | xargs -i -P 15 bash -c 'echo emalign '$BRICKID'.{}.0.0 && . ./align.sh '$BRICKID' {} > out_al/'$BRICKID'.{}.0.0.al.txt'
makescanset -set=$BRICKID.0.0.0 -dz=-1350 -from_plate=57 -to_plate=1 -dzbase=195
cp local_align.rootrc align.rootrc
seq 1 56 | xargs -i -P 15 bash -c 'echo emalign '$BRICKID'.{}.0.0 && . ./align.sh '$BRICKID' {} > out_al/'$BRICKID'.{}.0.0.al.txt'
makescanset -set=$BRICKID.0.0.0 -dz=-1350 -from_plate=57 -to_plate=1 -dzbase=195

