BRICKID=$1
i=$2
s=$3
if [ $(( i + s )) -le 57 ]; then
    tagalign -A=$BRICKID.$((i+s)).0.0 -B=$BRICKID.$((i)).0.0 -new -v=2 -side=1
fi
