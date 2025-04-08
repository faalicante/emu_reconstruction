#!/bin/bash

BRICKID=$1
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
export BRICKFOLDER  # So the inner function can access it
MISSING_FILE_LOG="missing_files.txt"
> $MISSING_FILE_LOG  # Empty log file

process_cell() {
    CELL=$1
    start_time=$(date +%s)
    
    xcell=$((CELL % 18 + 1))
    ycell=$((CELL / 18 + 1))
    folder=cell_${xcell}0_${ycell}0/$BRICKFOLDER
    file_aff=AFF.$CELL.tar.gz

    echo "[$(date +%H:%M:%S)] Starting cell $CELL"

    if [ -f "$folder/$file_aff" ]; then
        (
            cd "$folder"
            tar -xzf "$file_aff"
        )
    else
        echo "$file_aff is missing" | tee -a "$MISSING_FILE_LOG"
    fi

    end_time=$(date +%s)
    duration=$((end_time - start_time))
    echo "[$(date +%H:%M:%S)] Finished cell $CELL in ${duration}s"
}

export -f process_cell

seq 0 323 | parallel --jobs 90% --ungroup process_cell

counter_aff=$(wc -l < "$MISSING_FILE_LOG")
echo "Missing $counter_aff cp files."