#!/bin/bash

BRICKID=$1
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
export BRICKID BRICKFOLDER

MISSING_FILE_LOG="missing_cp_files.txt"
> "$MISSING_FILE_LOG"  # Clear the log

process_cell_cp() {
    CELL=$1
    xcell=$((CELL % 18 + 1))
    ycell=$((CELL / 18 + 1))
    folder=cell_${xcell}0_${ycell}0/$BRICKFOLDER
    counter_local=0

    echo "Checking cell $CELL"

    for p in $(seq 1 57); do
        plate=$(printf "p%03d" $p)
        base="$folder/$plate/$BRICKFOLDER.$p.$xcell.$ycell"
        file_mos="${base}.mos.root"
        file_cp="${base}.cp.root"
        file_cp_frag="${base}.0.cp.root"
        dest_base="$folder/$plate/$BRICKFOLDER.$p.0.0"

        if [ -f "$file_cp" ]; then
            mv "$file_mos" "$dest_base.mos.root" 2>/dev/null
            mv "$file_cp" "$dest_base.cp.root" 2>/dev/null
            if [ -f "$file_cp_frag" ]; then
                rm "$file_cp_frag"
            fi
        else
            echo "$file_cp is missing" | tee -a "$MISSING_FILE_LOG"
            ((counter_local++))
        fi
    done
}

export -f process_cell_cp

# Run in parallel
seq 0 323 | parallel --jobs 80% --ungroup process_cell_cp

# Final report
counter_cp=$(wc -l < "$MISSING_FILE_LOG")
echo "Missing $counter_cp cp files."