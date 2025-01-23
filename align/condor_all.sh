#!/bin/bash

RUN=1 #put run number
BRICKID=121 #put brick id
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
PREDICTION=5 #put shower prediction number

echo "Set up SND environment"
SNDBUILD_DIR=/afs/cern.ch/work/s/snd2na/public/SNDBUILD/sw
source /cvmfs/sndlhc.cern.ch/SNDLHC-2023/Aug30/setUp.sh
eval `alienv load -w $SNDBUILD_DIR --no-refresh sndsw/latest`
source /afs/cern.ch/work/s/snd2na/public/fedra/setup_new.sh

echo  "go into reconstruction folder "
cd /eos/experiment/sndlhc/emulsionData/2022/emureco_Napoli/RUN$RUN/$BRICKFOLDER/sh_$PREDICTION/$BRICKFOLDER

echo "align $BRICKID.0.0.0"
source scanset.sh $BRICKID
emalign -set=$BRICKID.0.0.0 -new -v=2