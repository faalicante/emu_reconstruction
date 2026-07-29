#!/usr/bin/env bash

if (( $# < 2 )); then
    echo "Usage: $0 fixed_number number [number ...]" >&2
    exit 1
fi

BRICKID=$1
shift

mapfile -t PLATENUMBER < <(printf '%s\n' "$@" | sort -n -u)

# Rename the plate folders to skip
for n in "${PLATENUMBER[@]}"; do
    PLATEFOLDER="$(printf "p%03d" $(( 10#$n )))"
    echo "Skipping plate $PLATEFOLDER -> $PLATEFOLDER.bad"
    mv $PLATEFOLDER $PLATEFOLDER.bad
done

# Build single/pair jobs
jobs=()

for ((i = 0; i < ${#PLATENUMBER[@]}; )); do
    current=${PLATENUMBER[i]}
    next=${PLATENUMBER[i + 1]:-}
    prev=$((current-1))

    if [[ -n $next ]] && (( next == current + 1 )); then
        jobs+=("pair $prev")
        ((i += 2))
    else
        jobs+=("single $prev")
        ((i += 1))
    fi
done

echo
echo "makescanset"
source scanset.sh $BRICKID > /dev/null

# First parallel phase
cp alignR2.rootrc align.rootrc
printf '%s\n' "${jobs[@]}" |
xargs -P 8 -I {} bash -c '
    read -r type plate <<< "$1"
    BRICKID=$2

    if [[ $type == pair ]]; then
        echo "second alignment $BRICKID $plate 3"
        source alignplate.sh $BRICKID $plate 3

    else
        echo "second alignment $BRICKID $plate 2"
        source alignplate.sh $BRICKID $plate 2
    fi
' _ "{}" "$BRICKID"

source scanset.sh $BRICKID > /dev/null
cp alignR1.rootrc align.rootrc
sed -i "s/2.5/5/" align.rootrc

# Second parallel phase
printf '%s\n' "${jobs[@]}" |
xargs -P 8 -I {} bash -c '
    read -r type plate <<< "$1"
    BRICKID=$2

    if [[ $type == pair ]]; then
        echo "third alignment $BRICKID $plate 3"
        source alignplate.sh $BRICKID $plate 3

    else
        echo "third alignment $BRICKID $plate 2"
        source alignplate.sh $BRICKID $plate 2
    fi
' _ "{}" "$BRICKID"

#Save reports
for job in "${jobs[@]}"; do
    read -r type plate <<< "$job"

    if [[ $type == pair ]]; then
        nextplate=$((plate+3))
    else
        nextplate=$((plate+2))
    fi

    root -l -b <<EOC
TFile *_file0 = TFile::Open("AFF/${BRICKID}.${nextplate}.0.0_${BRICKID}.${plate}.0.0.al.root")
report_al->SaveAs("${nextplate}_${plate}.png", "png");
.q
EOC

    eog ${nextplate}_${plate}.png &
done