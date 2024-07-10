#!/bin/bash

RUN=        #put run number
BRICKID=    #put brick id
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
PLATENUMBER=$3

echo "Set up SND environment"
SNDBUILD_DIR=/afs/cern.ch/work/s/snd2na/public/SNDBUILD/sw
#source /cvmfs/sndlhc.cern.ch/SNDLHC-2023/Aug30/setUp.sh
#eval `alienv load -w $SNDBUILD_DIR --no-refresh sndsw/latest`
#lates fedra not yet released
source /eos/user/s/snd2na/sw/fedra/setup_new.sh	

echo  "go into reconstruction folder "
cd /eos/experiment/sndlhc/emulsionData/2022/emureco_Napoli/RUN$RUN/$BRICKFOLDER

echo "viewsideal $BRICKID.$PLATENUMBER.0.0"
source viewsideal.sh $BRICKID $PLATENUMBER

echo "mostag $BRICKID.$PLATENUMBER.0.0"
source mostag.sh $BRICKID $PLATENUMBER
