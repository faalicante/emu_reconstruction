#!/bin/bash

RUN=$2
BRICKID=$3
BRICKFOLDER=$4
CELL=$5
xcell=$((CELL % 18 + 1))
ycell=$((CELL / 18 + 1))
EXP_PRE=$6
EXP_DIR=$EXP_PRE/RUN$RUN/$BRICKFOLDER/cells

echo "Set up SND environment"
SNDBUILD_DIR=/afs/cern.ch/user/s/snd2cern/public/SNDBUILD/sw
source /cvmfs/sndlhc.cern.ch/SNDLHC-2025/Oct7/setUp.sh
eval `alienv load -w $SNDBUILD_DIR --no-refresh sndsw/latest`
echo "Loading FEDRA"
source /afs/cern.ch/user/s/snd2cern/public/fedra/setup_new.sh

cd $EXP_DIR

root -l -b -q /afs/cern.ch/work/f/falicant/public/emu_reconstruction/5.tracking/check_t.C\($BRICKID,$xcell,$ycell\)