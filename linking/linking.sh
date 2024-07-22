BRICKID=$1

mkdir out_shr
seq 1 56 | xargs -i -P 15 bash -c 'echo emlink '$BRICKID'.{}.0.0 && emlink -id='$BRICKID'.{}.0.0 -new -v=2 > out_shr/'$BRICKID'.{}.0.0.link.txt'

