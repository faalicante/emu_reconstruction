#!/bin/bash

RUN=$2
BRICKID=$3
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
CELL=$4
EXP_PRE=$5
EXP_DIR=$EXP_PRE/RUN$RUN/$BRICKFOLDER/cells

echo "go into reconstruction folder "
cd $EXP_DIR

echo "make volume $CELL"
source make_volume.sh $BRICKID $CELL