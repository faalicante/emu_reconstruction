#!/usr/bin/env bash

if (( $# < 2 )); then
    echo "Usage: $0 <brickid> <cellid_list> [output_file]"
    exit 1
fi

brickid=$1
input=$2
output="trk_${brickid}.txt"

# Format brickid with 6 digits
brick=$(printf "b%06d" "$((10#$brickid))")

> "$output"

while read -r cellid; do

    # Skip empty lines
    [[ -z "$cellid" ]] && continue

    # Convert cellid to x, y
    cellid=$((10#$cellid))
    x=$(( (cellid % 18 + 1) * 10 ))
    y=$(( (cellid / 18 + 1) * 10 ))

    # Write path
    echo "cell_${x}_${y}/${brick}/${brick}.0.0.0.trk.root" >> "$output"

done < "$input"

echo "Generated $output"