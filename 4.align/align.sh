BRICKID=$1
PLATENUMBER=$2
emalign -A=$BRICKID.$((PLATENUMBER+1)).0.0 -B=$BRICKID.$((PLATENUMBER)).0.0 -new -v=1
