#!/bin/bash

export EOSSHIP=root://eospublic.cern.ch/

RUN= #put run number
BRICKID= #put brick id
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
PLATENUMBER=$2
PLATEFOLDER="$(printf "p%0*d" 3 $PLATENUMBER)"

echo "Set up SND environment"
SNDBUILD_DIR=/afs/cern.ch/work/s/snd2na/public/SNDBUILD/sw
source /cvmfs/sndlhc.cern.ch/SNDLHC-2023/Aug30/setUp.sh
eval `alienv load -w $SNDBUILD_DIR --no-refresh sndsw/latest`
echo "Loading FEDRA"
source /afs/cern.ch/work/s/snd2na/public/fedra/setup_new.sh	

cd $PWD
MY_DIR=${CELL}_{$PLATENUMBER}/$BRICKFOLDER
EXP_DIR=/eos/experiment/sndlhc/emulsionData/2022/emureco_Napoli/RUN$RUN/$BRICKFOLDER
mkdir -p -v ./$MY_DIR/out
mkdir -p -v ./$MY_DIR/$PLATEFOLDER
ln -s $EXP_DIR/$PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.raw.root ./$MY_DIR/$PLATEFOLDER
xrdcp $EXP_DIR/$PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.mos.root ./$MY_DIR/$PLATEFOLDER
xrdcp $EXP_DIR/$BRICKFOLDER.0.0.0.set.root ./$MY_DIR
xrdcp $EXP_DIR/mosalignbeam.sh ./$MY_DIR

cd $MY_DIR
source mosalignbeam.sh $BRICKID $PLATENUMBER

xrdcp -f out/ab0_$PLATENUMBER.txt $EXP_DIR/out/
xrdcp -f $PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.mos.root $EXP_DIR/$PLATEFOLDER/

cd ../
rm -rf ./$MY_DIR
