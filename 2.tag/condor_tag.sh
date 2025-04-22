#!/bin/bash

export EOSSHIP=root://eospublic.cern.ch/

RUN=$2
BRICKID=$3
BRICKFOLDER=$4
PLATENUMBER=$5
PLATEFOLDER=$6
EXP_PRE=$7
EXP_DIR=$EXP_PRE/RUN$RUN/$BRICKFOLDER

echo "Set up SND environment"
SNDBUILD_DIR=/afs/cern.ch/work/s/snd2na/public/SNDBUILD/sw
source /cvmfs/sndlhc.cern.ch/SNDLHC-2023/Aug30/setUp.sh
eval `alienv load -w $SNDBUILD_DIR --no-refresh sndsw/latest`
echo "Loading FEDRA"
source /afs/cern.ch/work/s/snd2na/public/fedra/setup_new.sh

export LD_PRELOAD=/cvmfs/sndlhc.cern.ch/SNDLHC-2023/Aug30/sw/slc9_x86-64/XRootD/latest/lib/libXrdPosixPreload.so
export XROOTD_VMP=eospublic.cern.ch:/eos=/eos

MAIN_DIR=$PWD
cd $MAIN_DIR
MY_DIR=$PLATENUMBER/$BRICKFOLDER
mkdir -p -v ./$MY_DIR/$PLATEFOLDER

ln -s $EXP_DIR/$PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.raw.root ./$MY_DIR/$PLATEFOLDER
ln -s $EXP_DIR/$BRICKFOLDER.0.0.0.set.root ./$MY_DIR
ln -s $EXP_DIR/mosalignbeam.sh ./$MY_DIR
ln -s $EXP_DIR/mostag.sh ./$MY_DIR

cd $MY_DIR

mv $MAIN_DIR/$BRICKID.$PLATENUMBER.0.0.mos.root  $PLATEFOLDER/
source mostag.sh $BRICKID $PLATENUMBER
mv $PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.tag.root $MAIN_DIR/
