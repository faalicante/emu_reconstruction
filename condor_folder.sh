#!/bin/bash

script_dir=/afs/cern.ch/work/f/falicant/public/emu_reconstruction

# Check if argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <option>"
  exit 1
fi

OPT="$1"

# Get today's date in yyyy_mm_dd format
TODAY=$(date +"%Y_%m_%d")

# Folder name
FOLDER="${TODAY}_${OPT}"

# Create folder
mkdir -p "$FOLDER/log"

# Decide what to copy based on argument
case "$OPT" in
  vsa)
    cp $script_dir/1.mosaic/condor_* $FOLDER
    ;;
  proc)
    cp $script_dir/3.cell_proc/condor_* $FOLDER
    cp $script_dir/3.cell_proc/create_dat.py $FOLDER
    cp $script_dir/4.align/condor_* $FOLDER
    ;;
  trk)
    cp $script_dir/5.tracking/condor_* $FOLDER
    ;;
  *)
    echo "Unknown option: $OPT"
    exit 1
    ;;
esac

echo "Folder '$FOLDER' created and files copied."
cd "$FOLDER"