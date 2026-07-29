#!/bin/bash
# =============================================================================
# run_plate.sh — Production single-plate FEDRA chain.
#
# Runs on a Condor batch node as whatever account submitted the job.
# All EOS I/O uses xrdcp (root://eospublic.cern.ch/) with the submitter's
# kerberos ticket — no FUSE mount needed on the batch node.
#
# Chain (full):
#   Stage 1  viewsideal  → <BRICK>.<N>.0.0.mos.root
#   Stage 2  mostag      → <BRICK>.<N>.0.0.tag.root   (done signal)
#   Stage 3  tagalign    → *.al.root, *.aff.par       (if adjacent tag.root ready)
#   Stage 4  check_mos / check_al → report/mos/mosNN.png, report/tal/NNN.png
#
# Layout (manual convention, proven for full-plate mosaic):
#   scratch/
#     <BRICKFOLDER>.0.0.0.set.root
#     viewsideal.rootrc  tagalign.rootrc
#     p<NNN>/<BRICK>.<N>.0.0.raw.root   (48 GB, copied from RAW_DIR/P<NNN>)
#   run viewsideal/mostag from scratch → p<NNN>/*.mos.root, *.tag.root
#
# Outputs go to  BRICK_DIR/p<NNN>/  (lowercase p, experiment space):
#   <BRICK>.<N>.0.0.mos.root
#   <BRICK>.<N>.0.0.tag.root                       (done signal)
#   <BRICK>.<HI>.0.0_<BRICK>.<LO>.0.0.al.root      (if alignment ran)
#   <BRICK>.<HI>.0.0_<BRICK>.<LO>.0.0.aff.par
#   pipeline.log
#
# Args (from condor_brick.sub):
#   $1  ClusterID
#   $2  BRICK        integer brick ID (e.g. 413)
#   $3  BRICK_DIR    experiment-space path to brick config dir (read/write)
#   $4  PLATENUMBER  plate integer (e.g. 5)
#   $5  IN_FILE      full experiment-space path to input raw.root
#   $6  RAW_MODE     copy (default, 48 GB → scratch) | link (FUSE symlink, no copy)
#   $7  HEADERCUT    optional viewsideal HeaderCut string (fast test on small area)
# =============================================================================

export EOSSHIP=root://eospublic.cern.ch/
export XRD=root://eospublic.cern.ch

BRICKID=$2
BRICK_DIR=$3
PLATENUMBER=$4
IN_FILE=$5
RAW_MODE=${6:-copy}       # copy | link  (link = read 48 GB raw via EOS FUSE, no copy)
HEADERCUT=${7:-}          # optional viewsideal HeaderCut (fast test on a small area)
SCRIPT_DIR=/eos/experiment/sndlhc/users/vacharit/poller   # dir containing check_mos.C, check_al.C

BRICKFOLDER=$(printf "b%06d" "$BRICKID")
PLATEFOLDER=$(printf "p%03d" "$PLATENUMBER")
DATA_PLATE_DIR="${BRICK_DIR}/${PLATEFOLDER}"

# --- EOS I/O helpers (everything is experiment space → xrdcp) ----------------
eos_get()   { xrdcp -f -N "${XRD}/$1" "$2"; }
eos_put()   { xrdcp -f -N "$1" "${XRD}/$2"; }
eos_mkdir() { xrdfs eospublic.cern.ch mkdir -p "$1" 2>/dev/null; }

# --- Self-logging: ship log back to the plate dir on exit --------------------
LOGFILE=/tmp/plate_${BRICKID}_${PLATENUMBER}_$$.log
exec > >(tee "$LOGFILE") 2>&1
trap '[ -n "$_SCRATCH" ] && rm -rf "$_SCRATCH" 2>/dev/null; \
      [ -n "$OMP_LIB_DIR" ] && rm -rf "$OMP_LIB_DIR" 2>/dev/null; \
      eos_put "$LOGFILE" "${DATA_PLATE_DIR}/pipeline.log" 2>/dev/null' EXIT

echo "===== run_plate.sh (production) ====="
echo "BRICK=$BRICKID  PLATE=$PLATENUMBER"
echo "IN_FILE=$IN_FILE"
echo "BRICK_DIR=$BRICK_DIR"
echo "DATA_PLATE_DIR=$DATA_PLATE_DIR"
echo "HOST=$(hostname)  DATE=$(date)"

# =============================================================================
# Environment
# =============================================================================
echo "=== Setting up SND + FEDRA ==="
SNDBUILD_DIR=/afs/cern.ch/user/s/snd2cern/public/SNDBUILD/sw
source /cvmfs/sndlhc.cern.ch/SNDLHC-2025/Oct7/setUp.sh
eval "$(alienv load -w "$SNDBUILD_DIR" --no-refresh sndsw/latest)"
source /afs/cern.ch/user/s/snd2cern/public/fedra/setup_new.sh

# OMP-optimized libMosaic + libAlignment (world-readable).
OMP_EOS_SRC=/eos/experiment/sndlhc/users/vacharit/fedra-perf/profiling_test/build_omp/lib
OMP_LIB_DIR=/tmp/fedra_omp_$$
mkdir -p "$OMP_LIB_DIR"
eos_get "$OMP_EOS_SRC/libMosaic.so"            "$OMP_LIB_DIR/" || { echo "ERROR: libMosaic.so fetch failed"; exit 1; }
eos_get "$OMP_EOS_SRC/libAlignment.so"         "$OMP_LIB_DIR/" || { echo "ERROR: libAlignment.so fetch failed"; exit 1; }
# Do NOT fetch .pcm dictionaries into OMP_LIB_DIR — ROOT 6 auto-discovers
# any .pcm file in LD_LIBRARY_PATH dirs, and FEDRA .pcm files interfere with
# ROOT's startup, causing root -b -q -e TFile::Open() to crash (false zombie).
# Do NOT add OMP_LIB_DIR to LD_LIBRARY_PATH for the same reason.
# We use LD_PRELOAD (inline, per FEDRA call) to bypass RPATH — that alone
# is sufficient: the .so files carry their own transitive dependencies.
_FEDRA_PRELOAD="$OMP_LIB_DIR/libMosaic.so:$OMP_LIB_DIR/libAlignment.so"
CPUS=$(nproc)
export OMP_NUM_THREADS=$CPUS OMP_PROC_BIND=close OMP_WAIT_POLICY=passive
export FEDRA_OMP_BATCH=$((CPUS * 2))
echo "OpenMP: threads=$OMP_NUM_THREADS  batch=$FEDRA_OMP_BATCH"
echo "OMP override: LD_PRELOAD=$_FEDRA_PRELOAD"
# Verify the OMP override: find the real ELF binary behind the wrapper,
# then check which libMosaic/libAlignment it resolves with LD_PRELOAD set.
_VSI_BIN=$(readlink -f "$(which viewsideal)" 2>/dev/null || which viewsideal)
echo "--- library load check (binary: $_VSI_BIN) ---"
LD_PRELOAD="$_FEDRA_PRELOAD" ldd "$_VSI_BIN" 2>/dev/null \
  | grep -E "libMosaic|libAlignment" || echo "  (ldd: no libMosaic/libAlignment — viewsideal may be an ELF or check failed)"
echo "--- end library check ---"
# =============================================================================
# Working directory — local scratch with the FEDRA-expected layout:
#   _SCRATCH/<BRICKFOLDER>/          ← cd here
#     <BRICKFOLDER>.0.0.0.set.root
#     viewsideal.rootrc  tagalign.rootrc
#     <PLATEFOLDER>/                 ← raw.root goes here
#     AFF/
# =============================================================================
_SCRATCH=$(mktemp -d /tmp/plate_${BRICKID}_${PLATENUMBER}_XXXXXX)
WORK_DIR="$_SCRATCH/$BRICKFOLDER"
mkdir -p "$WORK_DIR/$PLATEFOLDER" "$WORK_DIR/AFF"
cd "$WORK_DIR"
echo "scratch: $WORK_DIR"
eos_mkdir "$DATA_PLATE_DIR"

# =============================================================================
# Fetch FEDRA config from BRICK_DIR (read-only)
# =============================================================================
echo "=== Fetching FEDRA config from $BRICK_DIR ==="
eos_get "${BRICK_DIR}/${BRICKFOLDER}.0.0.0.set.root" "./${BRICKFOLDER}.0.0.0.set.root" \
  || { echo "ERROR: set.root fetch failed"; exit 3; }
eos_get "${BRICK_DIR}/viewsideal.rootrc" ./viewsideal.rootrc \
  || { echo "WARNING: viewsideal.rootrc not found; FEDRA defaults will be used"; }
# Optional HeaderCut injection (used by the fast test to restrict the area).
if [ -n "$HEADERCUT" ] && [ -f ./viewsideal.rootrc ]; then
  grep -v "HeaderCut" ./viewsideal.rootrc > ./viewsideal.rootrc.tmp
  printf 'fedra.vsa.HeaderCut:  %s\n' "$HEADERCUT" >> ./viewsideal.rootrc.tmp
  mv ./viewsideal.rootrc.tmp ./viewsideal.rootrc
  echo "viewsideal.rootrc: HeaderCut set to '$HEADERCUT'"
fi
if eos_get "${BRICK_DIR}/tagalign.rootrc" ./tagalign.rootrc.src 2>/dev/null; then
  sed 's|tagalign.outdir:.*|tagalign.outdir:  .|' ./tagalign.rootrc.src > ./tagalign.rootrc
  echo "tagalign.rootrc: outdir set to ."
else
  echo "WARNING: tagalign.rootrc not found; alignment will be skipped"
fi

# Fetch quality-plot macros from the same directory as this script
eos_get "${SCRIPT_DIR}/check_mos.C" ./check_mos.C 2>/dev/null \
  && echo "check_mos.C: fetched" || echo "WARNING: check_mos.C not found in ${SCRIPT_DIR}"
eos_get "${SCRIPT_DIR}/check_al.C"  ./check_al.C  2>/dev/null \
  && echo "check_al.C: fetched"  || echo "WARNING: check_al.C not found in ${SCRIPT_DIR}"

# Parse KRUN from brick.cfg (colour-scale factor for quality plots, default 1.0)
# Add a line  KRUN=0.5  to brick.cfg to override.
KRUN=1.0
if eos_get "${BRICK_DIR}/brick.cfg" ./brick.cfg.tmp 2>/dev/null; then
  while IFS= read -r _kline; do
    _kline="${_kline%%#*}"
    _kline="${_kline#"${_kline%%[![:space:]]*}"}"
    _kline="${_kline%"${_kline##*[![:space:]]}"}"  
    [[ "$_kline" =~ ^KRUN[[:space:]]*=[[:space:]]*([0-9.]+) ]] && KRUN="${BASH_REMATCH[1]}" && break
  done < ./brick.cfg.tmp
  rm -f ./brick.cfg.tmp
fi
echo "Quality plots: KRUN=${KRUN}"

# =============================================================================
# Fetch input raw.root (48 GB) → local scratch, FEDRA naming convention
# =============================================================================
RAW_LOCAL="$PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.raw.root"
if [ "$RAW_MODE" = "link" ]; then
  echo "=== raw access: FUSE symlink (no copy) ==="
  echo "  src : ${IN_FILE}"
  ln -s -f "${IN_FILE}" "./$RAW_LOCAL" \
    || { echo "ERROR: could not symlink raw (FUSE not available?)"; exit 2; }
  ls -lL "./$RAW_LOCAL" 2>/dev/null | awk '{print "  raw (via FUSE):", $5, "bytes"}'
else
  echo "=== fetching input (this is large) ==="
  echo "  src : ${IN_FILE}"
  echo "  dest: ./$RAW_LOCAL"
  eos_get "${IN_FILE}" "./$RAW_LOCAL" || { echo "ERROR: input raw.root fetch failed"; exit 2; }
  _local_sz=$(stat --format='%s' "./$RAW_LOCAL" 2>/dev/null || echo 0)
  echo "input: ${_local_sz} bytes"
  # Catch incomplete xrdcp: compare local size against the EOS source.
  # timeout 30s: xrdfs stat can hang indefinitely on EOS congestion (was killing whole 8h slot).
  _src_sz=$(timeout 30 xrdfs eospublic.cern.ch stat "${IN_FILE}" 2>/dev/null | awk '/^Size:/{print $2}')
  if [ -n "$_src_sz" ] && [ "$_src_sz" != "$_local_sz" ]; then
    echo "ERROR: raw.root size mismatch (src=${_src_sz} local=${_local_sz}) — Condor will retry"
    exit 2
  fi
fi

# Verify raw.root is a valid (non-zombie) ROOT file before spending hours on it.
# Only in copy mode: the file was just transferred by xrdcp and might be mid-write.
# In link mode the file lives on EOS and is already stable; TFile::Open over FUSE
# is unreliable (slow startup + 43 GB file → easily exceeds any timeout).
if [ "$RAW_MODE" != "link" ]; then
  if ! timeout 120 root -b -l -q -e "{TFile *_f=TFile::Open(\"${RAW_LOCAL}\");if(!_f||_f->IsZombie()){exit(1);}if(_f)_f->Close();}" 2>/dev/null; then
    echo "ERROR: raw.root is zombie/corrupt (or ROOT check timed out) — Condor will retry"
    exit 2
  fi
  echo "raw.root: validity check passed"
else
  echo "raw.root: validity check skipped (link mode, file is on EOS)"
fi

# =============================================================================
# Stage 1: mosaic
# =============================================================================
MOS_FILE="$PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.mos.root"
echo "----- Stage 1: viewsideal $BRICKID.$PLATENUMBER.0.0 -----"
LD_PRELOAD="$_FEDRA_PRELOAD" viewsideal -id="$BRICKID.$PLATENUMBER.0.0" -v=1
[ -s "$MOS_FILE" ] || { echo "ERROR: viewsideal produced no mos.root"; exit 4; }
echo "mos.root: $(stat --format='%s' "$MOS_FILE") bytes"
eos_put "$MOS_FILE" "${DATA_PLATE_DIR}/$(basename "$MOS_FILE")" \
  && echo "✓ mos.root → bricks uploaded" || echo "WARNING: mos.root upload failed"

# =============================================================================
# Stage 2: mostag
# =============================================================================
TAG_FILE="$PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.tag.root"
echo "----- Stage 2: mostag $BRICKID.$PLATENUMBER.0.0 -----"
LD_PRELOAD="$_FEDRA_PRELOAD" mostag -id="$BRICKID.$PLATENUMBER.0.0" -v=1
[ -s "$TAG_FILE" ] || { echo "ERROR: mostag produced no tag.root"; exit 5; }
echo "tag.root: $(stat --format='%s' "$TAG_FILE") bytes"
eos_put "$TAG_FILE" "${DATA_PLATE_DIR}/$(basename "$TAG_FILE")" \
  && echo "✓ tag.root → bricks uploaded (done signal)" || echo "WARNING: tag.root upload failed"

# Alignment state — set by Stage 3 if alignment succeeds
AL_ROOT=""   # path to the produced .al.root (empty = no alignment this run)
HI=0; LO=0  # high/low plate numbers of the aligned pair

# =============================================================================
# Stage 3: inter-plate alignment with an adjacent plate (if its tag.root exists).
# Adjacent tag.root looked up in BRICK_DIR/p<N±1>/  (lowercase p).
# align convention: -A=HIGH -B=LOW (higher plate number first).
# =============================================================================
echo "=== Stage 3: inter-plate alignment ==="
if [ ! -f ./tagalign.rootrc ]; then
  echo "  tagalign.rootrc unavailable — alignment skipped"
else
  ADJ_N_USED=""
  for TRY_N in $((PLATENUMBER + 1)) $((PLATENUMBER - 1)); do
    [ "$TRY_N" -lt 1 ] && continue
    TRY_FOLDER=$(printf "p%03d" "$TRY_N")
    CAND_TAG="${BRICK_DIR}/${TRY_FOLDER}/$BRICKID.$TRY_N.0.0.tag.root"
    mkdir -p "./$TRY_FOLDER"
    if eos_get "$CAND_TAG" "./$TRY_FOLDER/$BRICKID.$TRY_N.0.0.tag.root" 2>/dev/null; then
      ADJ_N_USED=$TRY_N
      echo "  adjacent plate $TRY_N found"
      break
    fi
  done

  if [ -z "$ADJ_N_USED" ]; then
    echo "  no adjacent plate available yet — alignment skipped"
    echo "  (a neighbour plate's own job will align against this one later)"
  else
    if [ "$ADJ_N_USED" -gt "$PLATENUMBER" ]; then HI=$ADJ_N_USED; LO=$PLATENUMBER
    else HI=$PLATENUMBER; LO=$ADJ_N_USED; fi
    echo "----- tagalign -A=$BRICKID.$HI.0.0 -B=$BRICKID.$LO.0.0 -----"
    LD_PRELOAD="$_FEDRA_PRELOAD" tagalign -A="$BRICKID.$HI.0.0" -B="$BRICKID.$LO.0.0" -new -v=2 -side=1
    LD_PRELOAD="$_FEDRA_PRELOAD" tagalign -A="$BRICKID.$HI.0.0" -B="$BRICKID.$LO.0.0" -v=2 -side=1
    AL_ROOT="AFF/$BRICKID.$HI.0.0_$BRICKID.$LO.0.0.al.root"
    AFF_FILE="AFF/$BRICKID.$HI.0.0_$BRICKID.$LO.0.0.aff.par"
    if [ -s "$AL_ROOT" ]; then
      # Alignment products go to the brick-level AFF/ dir (production layout),
      # NOT the plate dir — so the QA extractor finds them where check_al.C /
      # extract.py expect (brick_root/AFF/*.al.root).
      AFF_DEST="${BRICK_DIR}/AFF"
      eos_mkdir "$AFF_DEST"
      for f in "$AL_ROOT" "$AFF_FILE"; do
        [ -s "$f" ] || continue
        eos_put "$f" "${AFF_DEST}/$(basename "$f")" \
          && echo "✓ $(basename "$f") → bricks/AFF uploaded" \
          || echo "WARNING: $(basename "$f") upload failed"
      done
    else
      echo "WARNING: alignment ran but produced no al.root"
    fi
  fi
fi

# =============================================================================
# Stage 4: quality plots (mosaic + alignment)
# =============================================================================
echo "=== Stage 4: quality plots ==="

MOS_PNG_DIR="report/mos"
AL_PNG_DIR="report/tal"
mkdir -p "$MOS_PNG_DIR" "$AL_PNG_DIR"

# Mosaic quality plot — one PNG per plate (saved to brick report/mos, not plate)
if [ -s "${PLATEFOLDER}/${BRICKID}.${PLATENUMBER}.0.0.mos.root" ] && [ -f ./check_mos.C ]; then
  echo "  check_mos: plate ${PLATENUMBER} (kRun=${KRUN})"
  root -b -q "check_mos.C(${PLATENUMBER}, ${PLATENUMBER}, ${BRICKID}, ${KRUN}, \"${MOS_PNG_DIR}\")" \
    2>&1 | grep -v -E '(cling::|^\s*$|Warning in <TCanvas|^Info )' || true
  EOS_MOS_DIR="${BRICK_DIR}/report/mos"
  eos_mkdir "$EOS_MOS_DIR"
  for _png in "$MOS_PNG_DIR"/mos*.png; do
    [ -f "$_png" ] || continue
    eos_put "$_png" "${EOS_MOS_DIR}/$(basename "$_png")" \
      && echo "  ✓ $(basename "$_png") → ${EOS_MOS_DIR}" \
      || echo "  WARNING: upload failed: $_png"
  done
else
  if [ ! -s "${PLATEFOLDER}/${BRICKID}.${PLATENUMBER}.0.0.mos.root" ]; then
    echo "  check_mos: skipped (mos.root not present in ${PLATEFOLDER}/)"
  else
    echo "  check_mos: skipped (check_mos.C not found — SCRIPT_DIR='${SCRIPT_DIR}')"
  fi
fi

# Alignment quality plot — one PNG per adjacent-plate pair
if [ -n "$AL_ROOT" ] && [ -s "$AL_ROOT" ] && [ -f ./check_al.C ]; then
  echo "  check_al: plates ${LO}-${HI}"
  root -b -q "check_al.C(${LO}, ${LO}, ${BRICKID}, \"${AL_PNG_DIR}\")" \
    2>&1 | grep -v -E '(cling::|^\s*$|Warning in <TCanvas|^Info )' || true
  EOS_AL_DIR="${BRICK_DIR}/report/tal"
  eos_mkdir "$EOS_AL_DIR"
  for _png in "$AL_PNG_DIR"/*.png; do
    [ -f "$_png" ] || continue
    eos_put "$_png" "${EOS_AL_DIR}/$(basename "$_png")" \
      && echo "  ✓ $(basename "$_png") → ${EOS_AL_DIR}" \
      || echo "  WARNING: upload failed: $_png"
  done
else
  if [ -z "$AL_ROOT" ]; then
    echo "  check_al: skipped (no alignment this run)"
  elif [ ! -s "$AL_ROOT" ]; then
    echo "  check_al: skipped (al.root not found locally: ${AL_ROOT})"
  else
    echo "  check_al: skipped (check_al.C not found — SCRIPT_DIR='${SCRIPT_DIR}')"
  fi
fi

echo "===== run_plate.sh DONE ($(date)) ====="
