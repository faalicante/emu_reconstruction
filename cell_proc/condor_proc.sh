#!/bin/bash

export EOSSHIP=root://eospublic.cern.ch/

RUN=
BRICKID=
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
PLATENUMBER=$2
CELL=$3
xcell=$(((CELL % 18 + 1) * 10))
ycell=$(((CELL / 18 + 1) * 10))
CELLFOLDER=cell_${xcell}_${ycell}
PLATEFOLDER="$(printf "p%0*d" 3 $PLATENUMBER)"

echo "Set up SND environment"
SNDBUILD_DIR=/afs/cern.ch/work/s/snd2na/public/SNDBUILD/sw
source /cvmfs/sndlhc.cern.ch/SNDLHC-2023/Aug30/setUp.sh
eval `alienv load -w $SNDBUILD_DIR --no-refresh sndsw/latest`
source /afs/cern.ch/work/s/snd2na/public/fedra/setup_new.sh	

cd $PWD
MY_DIR=${CELL}_${PLATENUMBER}/$BRICKFOLDER
EXP_DIR=/eos/experiment/sndlhc/emulsionData/2022/emureco_Napoli/RUN1/b000123/cells/$CELLFOLDER/$BRICKFOLDER
mkdir -p -v ./$MY_DIR/$PLATEFOLDER

ln -s $EXP_DIR/$PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.raw.root ./$MY_DIR/$PLATEFOLDER
xrdcp $EXP_DIR/$BRICKFOLDER.0.0.0.set.root ./$MY_DIR
xrdcp $EXP_DIR/viewsideal.sh ./$MY_DIR
xrdcp $EXP_DIR/viewsideal.rootrc ./$MY_DIR
xrdcp $EXP_DIR/mosalignbeam.sh ./$MY_DIR
xrdcp $EXP_DIR/moslink.sh ./$MY_DIR
xrdcp $EXP_DIR/mosmerge.sh ./$MY_DIR
cd $MY_DIR

echo "viewsideal $BRICKID.$PLATENUMBER.0.0"
source viewsideal.sh $BRICKID $PLATENUMBER

echo "mosalignbeam $BRICKID.$PLATENUMBER.0.0"
source mosalignbeam.sh $BRICKID $PLATENUMBER

echo "moslink $BRICKID.$PLATENUMBER.0.0"
source moslink.sh $BRICKID $PLATENUMBER

echo "moslink merge $BRICKID.$PLATENUMBER.0.0"
source mosmerge.sh $BRICKID $PLATENUMBER

xrdcp -f $PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.mos.root $EXP_DIR/$PLATEFOLDER/
xrdcp -f $PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.*cp.root $EXP_DIR/$PLATEFOLDER/
cd ../
rm -rf ./$MY_DIR