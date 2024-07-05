#!/bin/bash
#usage: source create_link_miccern.sh run brick platelast platefirst 
#always check for rescans

RUN=$1
BRICKID=$2
NWALL=(${BRICKID: -2:1})
NBRICK=(${BRICKID: -1:1})
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
RAWDATAPATH=/eos/experiment/sndlhc/emulsionData/2022/CERN/SND_mic4/RUN$RUN/RUN$RUN\_W$NWALL\_B$NBRICK 
RECODATAPATH=/eos/experiment/sndlhc/emulsionData/2022/emureco_CERN/RUN$RUN/$BRICKFOLDER

for iplate in $(seq $4 $3)
  do

  RAWPLATEFOLDER="$(printf "P%03d" $(( 10#$iplate )))"
  # RAWPLATEFOLDER="$(printf "P%03d_RESCAN" $(( 10#$iplate )))"
  PLATEFOLDER="$(printf "p%03d" $(( 10#$iplate )))"
  mkdir $RECODATAPATH/$PLATEFOLDER
  ln -s -f $RAWDATAPATH/$RAWPLATEFOLDER/tracks.raw.root $RECODATAPATH/$PLATEFOLDER/$BRICKID.$iplate.0.0.raw.root
  echo created link for $PLATEFOLDER to $RAWDATAPATH/$RAWPLATEFOLDER

  done
