BRICKID=$1
shift
for PLATENUMBER in "$@"; do ###make parallel
    PLATEFOLDER="$(printf "p%03d" $(( 10#$PLATENUMBER )))"
    PLATETOALIGN=$((PLATENUMBER-1))
    
    mv $PLATEFOLDER $PLATEFOLDER.bad
    echo "Skipping plate $PLATEFOLDER -> $PLATEFOLDER.bad"

    echo
    echo "makescanset and second alignment"
    source scanset.sh $BRICKID > /dev/null
    cp alignR2.rootrc align.rootrc
    source alignplate.sh $BRICKID $PLATETOALIGN 2
    echo
    echo "makescanset and third alignment"
    source scanset.sh $BRICKID > /dev/null
    cp alignR1.rootrc align.rootrc
    source alignplate.sh $BRICKID $PLATETOALIGN 2
done