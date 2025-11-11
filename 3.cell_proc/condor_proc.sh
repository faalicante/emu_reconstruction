#!/bin/bash

export EOSSHIP=root://eospublic.cern.ch/

RUN=$2
BRICKID=$3
BRICKFOLDER=$4
CELL=$5
CELLFOLDER=$6
xcell=$((CELL % 18 + 1))
ycell=$((CELL / 18 + 1))
PLATENUMBER=$7
PLATEFOLDER=$8
EXP_PRE=$9
EXP_DIR=$EXP_PRE/RUN$RUN/$BRICKFOLDER/cells/$CELLFOLDER/$BRICKFOLDER

echo "Set up SND environment"
SNDBUILD_DIR=/afs/cern.ch/user/s/snd2cern/public/SNDBUILD/sw
source /cvmfs/sndlhc.cern.ch/SNDLHC-2025/Oct7/setUp.sh
eval `alienv load -w $SNDBUILD_DIR --no-refresh sndsw/latest`
echo "Loading FEDRA"
source /afs/cern.ch/user/s/snd2cern/public/fedra/setup_new.sh

export LD_PRELOAD=/cvmfs/sndlhc.cern.ch/SNDLHC-2025/Oct7/sw/slc9_x86-64/XRootD/latest/lib/libXrdPosixPreload.so
export XROOTD_VMP=eospublic.cern.ch:/eos=/eos

MAIN_DIR=$PWD
cd $MAIN_DIR
MY_DIR=${CELL}_${PLATENUMBER}/$BRICKFOLDER
mkdir -p -v ./$MY_DIR/$PLATEFOLDER

ln -s $EXP_DIR/$PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.raw.root ./$MY_DIR/$PLATEFOLDER
ln -s $EXP_DIR/$BRICKFOLDER.0.0.0.set.root ./$MY_DIR
ln -s $EXP_DIR/viewsideal.rootrc ./$MY_DIR
ln -s $EXP_DIR/viewsideal.sh ./$MY_DIR
ln -s $EXP_DIR/mosalignbeam.sh ./$MY_DIR
ln -s $EXP_DIR/moslink.sh ./$MY_DIR
ln -s $EXP_DIR/mosmerge.sh ./$MY_DIR

cd $MY_DIR

echo "viewsideal $BRICKID.$PLATENUMBER.0.0"
source viewsideal.sh $BRICKID $PLATENUMBER

echo "mosalignbeam $BRICKID.$PLATENUMBER.0.0"
source mosalignbeam.sh $BRICKID $PLATENUMBER

echo "moslink $BRICKID.$PLATENUMBER.0.0"
source moslink.sh $BRICKID $PLATENUMBER

echo "moslink merge $BRICKID.$PLATENUMBER.0.0"
source mosmerge.sh $BRICKID $PLATENUMBER

cp $PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.mos.root $MAIN_DIR/$BRICKID.$PLATENUMBER.$xcell.$ycell.mos.root
cp $PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.cp.root $MAIN_DIR/$BRICKID.$PLATENUMBER.$xcell.$ycell.cp.root