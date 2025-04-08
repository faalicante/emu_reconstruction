#!/bin/bash

BRICKID=$1
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
export BRICKID BRICKFOLDER

MISSING_FILE_LOG="missing_cp_files.txt"
> "$MISSING_FILE_LOG"  # Clear the log

process_cell_cp() {
    CELL=$1
    start_time=$(date +%s)

    xcell=$((CELL % 18 + 1))
    ycell=$((CELL / 18 + 1))
    folder=cell_${xcell}0_${ycell}0/$BRICKFOLDER
    counter_local=0

    echo "[$(date +%H:%M:%S)] Starting cell $CELL"

    for p in $(seq 1 57); do
        plate=$(printf "p%03d" $p)
        base="$folder/$plate/$BRICKID.$p.$xcell.$ycell"
        file_mos="${base}.mos.root"
        file_cp="${base}.cp.root"
        file_cp_frag="${base}.0.cp.root"
        dest_base="$folder/$plate/$BRICKID.$p.0.0"

        if [ -f "$file_cp" ]; then
            mv "$file_mos" "$dest_base.mos.root" 2>/dev/null
            mv "$file_cp" "$dest_base.cp.root" 2>/dev/null
            rm -f "$file_cp_frag"
        else
            echo "$file_cp is missing" | tee -a "$MISSING_FILE_LOG"
            ((counter_local++))
        fi
    done

    end_time=$(date +%s)
    duration=$((end_time - start_time))
    echo "[$(date +%H:%M:%S)] Finished cell $CELL in ${duration}s with $counter_local missing plates"
}

export -f process_cell_cp

# Run in parallel
seq 0 323 | parallel --jobs 90% --ungroup process_cell_cp

# Final report
counter_cp=$(wc -l < "$MISSING_FILE_LOG")
echo "Missing $counter_cp cp files."