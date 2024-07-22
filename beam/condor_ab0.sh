#!/bin/bash

RUN= #put run number
BRICKID= #put brick id
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
PLATENUMBER=$3

echo "Set up SND environment"
SNDBUILD_DIR= #put sndsw /sw path
source /cvmfs/sndlhc.cern.ch/SNDLHC-2023/Aug30/setUp.sh
eval `alienv load -w $SNDBUILD_DIR --no-refresh sndsw/latest`
echo "Loading FEDRA"
source #put /fedra/setup.sh 	

echo  "go into reconstruction folder "
cd # put reconstruction fodler /RUN$RUN/$BRICKFOLDER

echo "mosalignbeam $BRICKID.$PLATENUMBER.0.0"
source mosalignbeam.sh $BRICKID $PLATENUMBER

