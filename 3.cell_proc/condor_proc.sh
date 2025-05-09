#!/bin/bash

export EOSSHIP=root://eospublic.cern.ch/

RUN=$2
BRICKID=$3
BRICKFOLDER=$4
CELL=$5
CELLFOLDER=$6
xcell=$((CELL % 18 + 1))
ycell=$((CELL / 18 + 1))
EXP_PRE=$7
EXP_DIR=$EXP_PRE/RUN$RUN/$BRICKFOLDER/cells/$CELLFOLDER/$BRICKFOLDER

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

ln -s /eos/experiment/sndlhc/emulsionData/2022/CERN/CALIBRATIONS/mic4/diff_matrix_top_Dec23.txt ./$MY_DIR
ln -s /eos/experiment/sndlhc/emulsionData/2022/CERN/CALIBRATIONS/mic4/diff_matrix_bot_Dec23.txt ./$MY_DIR
for PLATENUMBER in $(seq 1 57); do
    PLATEFOLDER="$(printf "p%0*d" 3 $PLATENUMBER)"
    mkdir -p -v ./$MY_DIR/$PLATEFOLDER
    ln -s $EXP_DIR/$PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.raw.root ./$MY_DIR/$PLATEFOLDER
    ln -s $EXP_DIR/$PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.cp.root ./$MY_DIR/$PLATEFOLDER
done

ln -s $EXP_DIR/$BRICKFOLDER.0.0.0.set.root ./$MY_DIR
ln -s $EXP_DIR/viewsideal.rootrc ./$MY_DIR
ln -s $EXP_DIR/viewsideal_set.sh ./$MY_DIR
ln -s $EXP_DIR/mosalignbeam.sh ./$MY_DIR
ln -s $EXP_DIR/moslink.sh ./$MY_DIR
ln -s $EXP_DIR/mosmerge.sh ./$MY_DIR

cd $MY_DIR

echo "viewsideal $BRICKID.0.0.0"
source viewsideal_set.sh $BRICKID

echo "mosalignbeam $BRICKID.0.0.0"
source mosalignbeam.sh $BRICKID

echo "moslink $BRICKID.0.0.0"
source moslink.sh $BRICKID

echo "moslink merge $BRICKID.0.0.0"
source mosmerge.sh $BRICKID

for PLATENUMBER in $(seq 1 57); do
    PLATEFOLDER="$(printf "p%0*d" 3 $PLATENUMBER)"
    xrdcp -f $PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.mos.root $EXP_DIR/$PLATEFOLDER
    mv $PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.cp.root $EXP_DIR/$PLATEFOLDER
done