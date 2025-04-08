#!/bin/bash

export EOSSHIP=root://eospublic.cern.ch/

RUN=$2
BRICKID=$3
BRICKFOLDER=$4
CELL=$5
CELLFOLDER=$6
xcell=$((CELL % 18 + 1))
ycell=$((CELL / 18 + 1))
EXP_DIR=/eos/experiment/sndlhc/emulsionData/2022/emureco_CERN/RUN$RUN/$BRICKFOLDER/cells/$CELLFOLDER/$BRICKFOLDER

echo "Set up SND environment"
SNDBUILD_DIR=/afs/cern.ch/user/s/snd2cern/public/SNDBUILD/sw
source /cvmfs/sndlhc.cern.ch/SNDLHC-2023/Aug30/setUp.sh
eval `alienv load -w $SNDBUILD_DIR --no-refresh sndsw/latest`
echo "Loading FEDRA"
source /afs/cern.ch/user/s/snd2cern/public/fedra/setup_new.sh

export LD_PRELOAD=/cvmfs/sndlhc.cern.ch/SNDLHC-2023/Aug30/sw/slc9_x86-64/XRootD/latest/lib/libXrdPosixPreload.so
export XROOTD_VMP=eospublic.cern.ch:/eos=/eos

MAIN_DIR=$PWD
cd $MAIN_DIR
MY_DIR=${CELL}/$BRICKFOLDER
for PLATENUMBER in $(seq 1 57); do
    PLATEFOLDER="$(printf "p%0*d" 3 $PLATENUMBER)"
    mkdir -p -v ./$MY_DIR/$PLATEFOLDER
    ln -s $EXP_DIR/$PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.raw.root ./$MY_DIR/$PLATEFOLDER
    ln -s $EXP_DIR/$PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.cp.root ./$MY_DIR/$PLATEFOLDER
done
mv $MAIN_DIR/$BRICKID.0.0.0.set.root ./$MY_DIR
ln -s $EXP_DIR/tracking_all.sh ./$MY_DIR
ln -s $EXP_DIR/track*.rootrc ./$MY_DIR
ln -s $EXP_DIR/unbend*.rootrc ./$MY_DIR

cd $MY_DIR

echo "tracking $BRICKID.0.0.0"
source tracking_all.sh $BRICKID
mv $BRICKID.0.0.0.set.root $MAIN_DIR/$BRICKID.0.$xcell.$ycell.set.root
mv $BRICKID.0.0.0.trk.root $MAIN_DIR/$BRICKID.0.$xcell.$ycell.trk.root
mv unbend.root $MAIN_DIR/unbend.$xcell.$ycell.root
