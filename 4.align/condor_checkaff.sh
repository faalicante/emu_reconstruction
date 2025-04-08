#!/bin/bash

RUN=$2
BRICKID=$3
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
CELL=$4

echo "go into reconstruction folder "
cd /eos/experiment/sndlhc/emulsionData/2022/emureco_CERN/RUN$RUN/$BRICKFOLDER/cells

echo "Processing cell $CELL"
source fileaff_check.sh $BRICKID $CELL
