#!/bin/bash

RUN=$2
BRICKID=$3
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
CELL=$4

echo "Set up SND environment"
SNDBUILD_DIR=/afs/cern.ch/user/s/snd2cern/public/SNDBUILD/sw
source /cvmfs/sndlhc.cern.ch/SNDLHC-2023/Aug30/setUp.sh
eval `alienv load -w $SNDBUILD_DIR --no-refresh sndsw/latest`
echo "Loading FEDRA"
source /afs/cern.ch/user/s/snd2cern/public/fedra/setup_new.sh	

echo "go into reconstruction folder "
cd /eos/experiment/sndlhc/emulsionData/2022/emureco_CERN/RUN$RUN/$BRICKFOLDER/cells

echo "make volume $CELL"
source make_volume.sh $BRICKID $CELL