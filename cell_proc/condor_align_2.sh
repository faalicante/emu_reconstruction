#!/bin/bash

RUN= #put run number
BRICKID= #put brick id
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
PLATENUMBER=$3
CELL=$4
xcell=$(((CELL % 18 + 1) * 10))
ycell=$(((CELL / 18 + 1) * 10))
CELLFOLDER=cell_${xcell}_${ycell}

echo "Set up SND environment"
SNDBUILD_DIR=/afs/cern.ch/work/s/snd2na/public/SNDBUILD/sw
source /cvmfs/sndlhc.cern.ch/SNDLHC-2023/Aug30/setUp.sh
eval `alienv load -w $SNDBUILD_DIR --no-refresh sndsw/latest`
echo "Loading FEDRA"
source /afs/cern.ch/work/s/snd2na/public/fedra/setup_new.sh	

echo  "go into reconstruction folder "
cd /eos/experiment/sndlhc/emulsionData/2022/emureco_Napoli/RUN$RUN/$BRICKFOLDER/cells/$CELLFOLDER/$BRICKFOLDER

echo "align_2 $BRICKID.$PLATENUMBER.0.0"
cp align_2.rootrc align.rootrc
source alignplate.sh $BRICKID $PLATENUMBER > out/$BRICKID.$PLATENUMBER.0.0.al2.txt
# cp $BRICKFOLDER.0.0.0.align.ps plot_second_align/$BRICKFOLDER.0.0.0.secondalign.ps