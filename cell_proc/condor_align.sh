#!/bin/bash

export EOSSHIP=root://eospublic.cern.ch/

RUN=  #put run number
BRICKID= #put brick id
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
CELL=$2
xcell=$(((CELL % 18 + 1) * 10))
ycell=$(((CELL / 18 + 1) * 10))
CELLFOLDER=cell_${xcell}_${ycell}

echo "Set up SND environment"
SNDBUILD_DIR=/afs/cern.ch/work/s/snd2na/public/SNDBUILD/sw
source /cvmfs/sndlhc.cern.ch/SNDLHC-2023/Aug30/setUp.sh
eval `alienv load -w $SNDBUILD_DIR --no-refresh sndsw/latest`
echo "Loading FEDRA"
source /afs/cern.ch/work/s/snd2na/public/fedra/setup_new.sh	

cd $PWD
MY_DIR=$CELL/$BRICKFOLDER
EXP_DIR=/eos/experiment/sndlhc/emulsionData/2022/emureco_Napoli/RUN1/b000123/cells/$CELLFOLDER/$BRICKFOLDER
mkdir -p -v ./$MY_DIR/plot_second_align
mkdir -p -v ./$MY_DIR/plot_third_align
for PLATENUMBER in $(seq 1 57); do
    PLATEFOLDER="$(printf "p%0*d" 3 $PLATENUMBER)"
    mkdir -p -v ./$MY_DIR/$PLATEFOLDER
    ln -s $EXP_DIR/$PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.raw.root ./$MY_DIR/$PLATEFOLDER
    ln -s $EXP_DIR/$PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.cp.root ./$MY_DIR/$PLATEFOLDER
done
xrdcp -r $EXP_DIR/AFF ./$MY_DIR
xrdcp $EXP_DIR/align.sh ./$MY_DIR
xrdcp $EXP_DIR/align*.rootrc ./$MY_DIR
cd $MY_DIR
source align.sh $BRICKID

xrdcp -rf AFF $EXP_DIR/
xrdcp -rf plot_second_align $EXP_DIR/
xrdcp -rf plot_third_align $EXP_DIR/

cd ../
rm -rf ./$MY_DIR