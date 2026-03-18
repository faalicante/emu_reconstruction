BRICKID=$1
PLATENUMBER=$2

echo "viewsideal $BRICKID.$PLATENUMBER.0.0"
source viewsideal.sh $BRICKID $PLATENUMBER

echo "mosalignbeam $BRICKID.$PLATENUMBER.0.0"
source mosalignbeam.sh $BRICKID $PLATENUMBER

echo "moslink $BRICKID.$PLATENUMBER.0.0"
source moslink.sh $BRICKID $PLATENUMBER

echo "moslink merge $BRICKID.$PLATENUMBER.0.0"
source mosmerge.sh $BRICKID $PLATENUMBER