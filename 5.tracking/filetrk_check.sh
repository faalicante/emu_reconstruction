#!/bin/bash

BRICKID=$1
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
export BRICKID BRICKFOLDER

MISSING_FILE_LOG="missing_trk_files.txt"
> "$MISSING_FILE_LOG"  # Clear the log

process_cell_trk() {
    CELL=$1
    xcell=$((CELL % 18 + 1))
    ycell=$((CELL / 18 + 1))
    folder=cell_${xcell}0_${ycell}0/$BRICKFOLDER
    counter_local=0

    echo "Checking cell $CELL"

    base="$folder/$BRICKFOLDER.0.$xcell.$ycell"
    file_set="${base}.set.root"
    file_trk="${base}.trk.root"
    dest_base="$folder/$BRICKFOLDER.0.0.0"

    if [ -f "$file_trk" ]; then
        mv "$file_set" "$dest_base.set.root" 2>/dev/null
        mv "$file_trk" "$dest_base.trk.root" 2>/dev/null
    else
        echo "$file_trk is missing" | tee -a "$MISSING_FILE_LOG"
        ((counter_local++))
    fi
}

export -f process_cell_trk
export MISSING_FILE_LOG
# Run in parallel
seq 0 323 | parallel --jobs 80% --ungroup process_cell_trk

# Final report
counter=$(wc -l < "$MISSING_FILE_LOG")
echo "Missing $counter trk files."