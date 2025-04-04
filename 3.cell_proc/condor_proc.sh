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

ln -s /eos/experiment/sndlhc/emulsionData/2022/CERN/CALIBRATIONS/mic4/diff_matrix_top_Dec23.txt ./$MY_DIR
ln -s /eos/experiment/sndlhc/emulsionData/2022/CERN/CALIBRATIONS/mic4/diff_matrix_bot_Dec23.txt ./$MY_DIR
ln -s $EXP_DIR/$PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.raw.root ./$MY_DIR/$PLATEFOLDER
ln -s $EXP_DIR/$BRICKFOLDER.0.0.0.set.root ./$MY_DIR
ln -s $EXP_DIR/viewsideal.sh ./$MY_DIR
ln -s $EXP_DIR/viewsideal.rootrc ./$MY_DIR
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


mv $PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.mos.root $MAIN_DIR/$BRICKID.$PLATENUMBER.$xcell.$ycell.mos.root
mv $PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.cp.root $MAIN_DIR/$BRICKID.$PLATENUMBER.$xcell.$ycell.cp.root