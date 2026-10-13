#!/bin/bash

BRICK_ID=$1
INPUT_LIST="trk_${BRICK_ID}.txt"
TMP_DIR="tmp_plots_${BRICK_ID}"

trap 'echo -e "\n[!] Ctrl+C detected. Cleaning up processes..."; kill 0; exit 1' SIGINT SIGTERM

mkdir -p "${TMP_DIR}"
rm -f "${TMP_DIR}"/*.root

echo "Pre-compiling C++ macro..."
root -l -b -q "process_single_file.C+" > /dev/null 2>&1

# Verify the .so file was generated
if [ ! -f "process_single_file_C.so" ]; then
    echo "Error: Failed to compile process_single_file.C"
    exit 1
fi

#echo "Warm up input files"
#xargs -P 8 -a "$INPUT_LIST" cat > /dev/null 2>&1

echo "Processing files in parallel using pre-compiled library..."

nl -w1 -s' ' "$INPUT_LIST" | xargs -P 24 -L 1 sh -c '
    INDEX="$1"
    FILE="$2"
    OUT_FILE="'"${TMP_DIR}"'/file_${INDEX}_hist.root"

    # Stagger initial process starts by 1.5 seconds per slot
    # Modulo (% 32) ensures recycled workers do not wait unnecessarily
    DELAY=$(awk "BEGIN {print (($INDEX - 1) % 32) * 1.0}")
    sleep "$DELAY"

    echo "Starting process $INDEX (staggered delay: ${DELAY}s) for ${FILE}"

    # Load the pre-compiled .so library directly using ROOT gSystem
    exec root -l -b -q -e "ROOT::DisableImplicitMT();" "process_single_file_C.so(\"$FILE\", \"$OUT_FILE\")" > /dev/null 2>&1
' _

echo "Merging temporary histogram collections into master file..."

if [ -n "$(ls -A ${TMP_DIR}/*_hist.root 2>/dev/null)" ]; then
    hadd -f "merged_summary_${BRICK_ID}.root" ${TMP_DIR}/*_hist.root
    echo "Done! Final consolidated plots saved to: merged_summary_${BRICK_ID}.root"
    sleep 2
    root -l -b -q "draw_brick_summary.C(\"$BRICK_ID\")"
else
    echo "Error: Processing run finished but no histograms were written."
fi