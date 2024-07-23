BRICKID=$1
i=$2
tagalign -A=$BRICKID.$((i+1)).0.0 -B=$BRICKID.$((i)).0.0 -new -v=2
