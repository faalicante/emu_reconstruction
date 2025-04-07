#!/bin/bash

export EOSSHIP=root://eospublic.cern.ch/

RUN=$2
BRICKID=$3
BRICKFOLDER=$4
CELL=$5
CELLFOLDER=$6
PLATENUMBER=$7
PLATEFOLDER=$8
xcell=$((CELL % 18 + 1))
ycell=$((CELL / 18 + 1))
PLATENEXT=$((PLATENUMBER+1))
NEXTFOLDER="$(printf "p%0*d" 3 $PLATENEXT)"


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
MY_DIR=${CELL}_${PLATENUMBER}/$BRICKFOLDER
EXP_DIR=/eos/experiment/sndlhc/emulsionData/2022/emureco_CERN/RUN$RUN/$BRICKFOLDER/cells/$CELLFOLDER/$BRICKFOLDER
mkdir -p -v ./$MY_DIR/$PLATEFOLDER
mkdir -p -v ./$MY_DIR/$NEXTFOLDER
mkdir -p -v ./$MY_DIR/AFF

ln -s $EXP_DIR/$PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.raw.root ./$MY_DIR/$PLATEFOLDER
ln -s $EXP_DIR/$NEXTFOLDER/$BRICKID.$PLATENEXT.0.0.raw.root ./$MY_DIR/$NEXTFOLDER
ln -s $EXP_DIR/$PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.cp.root ./$MY_DIR/$PLATEFOLDER
ln -s $EXP_DIR/$NEXTFOLDER/$BRICKID.$PLATENEXT.0.0.cp.root ./$MY_DIR/$NEXTFOLDER
ln -s $EXP_DIR/scanset.sh ./$MY_DIR
ln -s $EXP_DIR/alignplate.sh ./$MY_DIR
ln -s $EXP_DIR/align_*.rootrc ./$MY_DIR

cd $MY_DIR

mv $MAIN_DIR/$BRICKID.$PLATENEXT.0.0_$BRICKID.$PLATENUMBER.0.0.aff.par ./AFF

echo "makescanset $BRICKID.0.0.0"
source scanset.sh $BRICKID
cp align_2.rootrc align.rootrc
echo "align 2 $BRICKID.$PLATENUMBER.0.0"
source alignplate.sh $BRICKID $PLATENUMBER
echo "makescanset $BRICKID.0.0.0"
source scanset.sh $BRICKID
cp align_3.rootrc align.rootrc
echo "align 3 $BRICKID.$PLATENUMBER.0.0"
source alignplate.sh $BRICKID $PLATENUMBER

mv AFF/$BRICKID.$PLATENEXT.0.0_$BRICKID.$PLATENUMBER.0.0.al.root $MAIN_DIR/$BRICKID.$PLATENEXT.0.0_$BRICKID.$PLATENUMBER.$xcell.$ycell.al.root
mv AFF/$BRICKID.$PLATENEXT.0.0_$BRICKID.$PLATENUMBER.0.0.aff.par $MAIN_DIR/$BRICKID.$PLATENEXT.0.0_$BRICKID.$PLATENUMBER.$xcell.$ycell.aff.par