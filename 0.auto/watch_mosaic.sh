#!/bin/bash
# =============================================================================
# watch_mosaic.sh — Production mosaic watcher (SND-LHC emulsion reconstruction).
#   ONE acrontab entry covers ALL bricks, forever.
#
# For every brick directory in BRICKS_SEARCH_ROOTS that has a brick.cfg, reads
# the RAW_DIR variable (where the microscope deposits P<NNN>/tracks.raw.root).
# For each plate whose raw file has arrived:
#   1. creates BRICK_DIR/p<NNN>/  and a provenance symlink
#          <BRICK>.<N>.0.0.raw.root -> RAW_DIR/P<NNN>/tracks.raw.root
#   2. submits one condor job that runs the full FEDRA chain
#          viewsideal -> mostag -> tagalign
#      writing <BRICK>.<N>.0.0.{mos,tag,al}.root into BRICK_DIR/p<NNN>/.
#
# Done signal (per plate):  BRICK_DIR/p<NNN>/<BRICK>.<N>.0.0.tag.root
#
# brick.cfg is the interface to the reconstruction jobs.  Recognised lines:
#   RAW_DIR=<base>        base dir for resolving bare plate numbers
#   <plate>               reconstruct plate; raw = RAW_DIR/P<NNN>/tracks.raw.root
#   <plate> : <spec>      reconstruct plate with explicit path; spec may be:
#                            P007_RESCAN            -> RAW_DIR/P007_RESCAN/tracks.raw.root
#                            /abs/dir               -> /abs/dir/tracks.raw.root
#                            /abs/file.raw.root     -> used verbatim
#   <plate> = <spec>      same as ':'
# Plates NOT listed are NEVER processed (explicit opt-in only).
# A brick with no plate lines is skipped.
# tag.root present = plate done, never resubmitted.
#
# Example brick.cfg:
#   RAW_DIR=/eos/experiment/sndlhc/emulsionData/CERN/SND/RUN4/RUN4_W1_B3
#   14
#   15
#   27 : P027_RESCAN
#   32 : /eos/experiment/sndlhc/emulsionData/CERN/SND_mic3/RUN4/P032/tracks.raw.root
#
# Adding a new brick:
#   1. make_brick.sh + scanset.sh  (set.root, viewsideal.rootrc, tagalign.rootrc)
#   2. write brick.cfg with RAW_DIR and the plate numbers to process
#   3. Nothing else.
#
# Acrontab (ONE line, forever — any account, no extra env vars needed):
#   */5 * * * * lxplus.cern.ch /eos/experiment/sndlhc/users/vacharit/poller/watch_mosaic.sh \
#       >> /eos/experiment/sndlhc/users/vacharit/poller/watch_mosaic.log 2>&1
# =============================================================================

# Directories to scan for brick.cfg files.
# Each entry is a tree root; the script finds b{NNNNNN} dirs at depth 2–4 within each.
BRICKS_SEARCH_ROOTS=(
  /eos/experiment/sndlhc/emulsionData/emureco_CERN
  /eos/experiment/sndlhc/emulsionData/emureco_Napoli
)
PIPE_DIR=/eos/experiment/sndlhc/users/vacharit/poller   # scripts, macros, state, logs
SUBMIT_FILE=${PIPE_DIR}/condor_brick.sub

# workday flavour = 8 h wall limit. With OMP, normal plates finish in ~2 h,
# but large plates can take up to ~8 h. Set the resubmit threshold well above
# the flavour wall so a job is never double-submitted while still running.
# The previous 9 h threshold was causing infinite resubmit loops: serial jobs
# (8-10 h) exceeded it, the watcher resubmitted, the workday limit killed the
# original at 8 h, repeat forever.
RESUBMIT_AFTER_S=86400          # 24 h


log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

# Resolve a per-plate raw spec into a full path to the raw.root file.
#   resolve_raw <spec> <RAW_DIR> <plateNumber>
# <spec> may be:
#   ""                       -> RAW_DIR/P<NNN>/tracks.raw.root
#   P007_RESCAN              -> RAW_DIR/P007_RESCAN/tracks.raw.root   (relative)
#   P007_RESCAN/foo.raw.root -> RAW_DIR/P007_RESCAN/foo.raw.root      (relative)
#   /abs/.../P009            -> /abs/.../P009/tracks.raw.root         (absolute dir)
#   /abs/.../foo.raw.root    -> used verbatim                        (absolute file)
resolve_raw() {
  local spec="$1" base="$2" n="$3" candidate
  if [ -z "$spec" ]; then
    # Try P%03d, P%02d, P%d — handle CERN (P001) and Napoli (P01) conventions.
    for fmt in "P%03d" "P%02d" "P%d"; do
      candidate="${base%/}/$(printf "$fmt" "$n")/tracks.raw.root"
      [ -f "$candidate" ] && { echo "$candidate"; return; }
    done
    # Return the canonical 3-digit form even if not found (caller checks existence).
    echo "${base%/}/$(printf "P%03d" "$n")/tracks.raw.root"
  elif [[ "$spec" == /* ]]; then
    if [[ "$spec" == *.root ]]; then echo "$spec"; else echo "${spec%/}/tracks.raw.root"; fi
  else
    if [[ "$spec" == *.root ]]; then echo "${base%/}/${spec}"; else echo "${base%/}/${spec%/}/tracks.raw.root"; fi
  fi
}

# --- single-instance lock (inside PIPE_DIR, vacharit-owned) ---
LOCK_DIR=${PIPE_DIR}/.watch_mosaic.lock
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  LOCK_AGE=$(( $(date +%s) - $(stat -c %Y "$LOCK_DIR" 2>/dev/null || echo 0) ))
  [ "$LOCK_AGE" -lt 1800 ] && { log "already running (lock age=${LOCK_AGE}s); exit"; exit 0; }
  log "stale lock (age=${LOCK_AGE}s); taking over"
  rmdir "$LOCK_DIR" 2>/dev/null && mkdir "$LOCK_DIR" 2>/dev/null \
    || { log "cannot acquire lock; exit"; exit 0; }
fi
trap 'rmdir "$LOCK_DIR" 2>/dev/null' EXIT

# --- HTCondor / EosSubmit schedd (forwards kerberos for xrdcp) ---------------
if ! type module &>/dev/null 2>&1; then
  for _L in /usr/share/lmod/lmod/init/bash /usr/share/Modules/init/bash /etc/profile.d/lmod.sh; do
    [ -f "$_L" ] && { . "$_L"; break; }
  done
fi
type module &>/dev/null 2>&1 && module load lxbatch/eossubmit

log "====== watch_mosaic start ====="

while IFS= read -r -d '' BRICK_DIR; do
  BRICK_DIR="${BRICK_DIR%/}"
  BRICKFOLDER=$(basename "$BRICK_DIR")            # b000413
  BRICK=$(echo "$BRICKFOLDER" | sed 's/^b0*//')   # 413

  CFG="$BRICK_DIR/brick.cfg"
  [ -f "$CFG" ] || continue

  # -----------------------------------------------------------------------
  # Parse brick.cfg.  Recognised lines (comments after # ignored):
  #   RAW_DIR=<base>           optional base dir for bare plate numbers
  #   <plate>                  process plate, raw = RAW_DIR/P<NNN>/tracks.raw.root
  #   <plate> : <spec>         process plate, raw resolved from <spec> (see resolve_raw)
  #   <plate> = <spec>         same as ':'
  # If ANY plate lines are present, ONLY those plates are processed.
  # If NO plate lines are present, every RAW_DIR/P<NNN>/tracks.raw.root is processed.
  # -----------------------------------------------------------------------
  RAW_DIR=""
  PLATE_NS=(); PLATE_SPECS=()
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%$'\r'}"
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"      # ltrim
    line="${line%"${line##*[![:space:]]}"}"      # rtrim
    [ -z "$line" ] && continue
    if [[ "$line" =~ ^RAW_DIR[[:space:]]*=[[:space:]]*(.*)$ ]]; then
      RAW_DIR="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^([0-9]+)[[:space:]]*[:=]?[[:space:]]*(.*)$ ]]; then
      PLATE_NS+=("${BASH_REMATCH[1]}")
      PLATE_SPECS+=("${BASH_REMATCH[2]}")
    fi
  done < "$CFG"

  SET_ROOT="$BRICK_DIR/${BRICKFOLDER}.0.0.0.set.root"
  [ -f "$SET_ROOT" ] || continue

  # State markers: .submitted/ dir lives in the brick dir alongside brick.cfg.
  STATE_DIR="${BRICK_DIR}/.submitted"
  mkdir -p "$STATE_DIR" "${BRICK_DIR}/log" 2>/dev/null

  # If NO plate lines are present, skip this brick (require explicit opt-in).
  [ "${#PLATE_NS[@]}" -eq 0 ] && continue

  # Process each requested plate.
  for i in "${!PLATE_NS[@]}"; do
    N="${PLATE_NS[$i]}"
    SRC=$(resolve_raw "${PLATE_SPECS[$i]}" "$RAW_DIR" "$N")
    [ -f "$SRC" ] || continue                      # raw not transferred yet

    PLATEFOLDER=$(printf "p%03d" "$N")
    DATA_PLATE_DIR="${BRICK_DIR}/${PLATEFOLDER}"

    # Done? tag.root already produced.
    DONE_SIG="${DATA_PLATE_DIR}/${BRICK}.${N}.0.0.tag.root"
    [ -f "$DONE_SIG" ] && continue

    # Resubmit throttle.
    MARKER="$STATE_DIR/plate_${N}"
    if [ -f "$MARKER" ]; then
      AGE=$(( $(date +%s) - $(stat -c %Y "$MARKER" 2>/dev/null || echo 0) ))
      [ "$AGE" -lt "$RESUBMIT_AFTER_S" ] && continue
      log "  $BRICKFOLDER/p$(printf '%03d' "$N"): marker ${AGE}s old, resubmitting"
    fi

    # Provenance: create plate dir + symlink to the exact raw file used.
    mkdir -p "$DATA_PLATE_DIR" 2>/dev/null
    ln -s -f "$SRC" "${DATA_PLATE_DIR}/${BRICK}.${N}.0.0.raw.root" 2>/dev/null

    # Determine JOBFLAVOUR based on raw file size.
    SRC_SIZE=$(stat -c %s "$SRC" 2>/dev/null || echo 0)
    SRC_GB=$(awk "BEGIN {printf \"%.1f\", $SRC_SIZE / 1e9}")
    if awk "BEGIN {exit !($SRC_SIZE < 1e9)}"; then
      JOBFLAVOUR="espresso"
    elif awk "BEGIN {exit !($SRC_SIZE < 10e9)}"; then
      JOBFLAVOUR="microcentury"
    elif awk "BEGIN {exit !($SRC_SIZE < 20e9)}"; then
      JOBFLAVOUR="longlunch"
    elif awk "BEGIN {exit !($SRC_SIZE < 40e9)}"; then
      JOBFLAVOUR="workday"
    else
      JOBFLAVOUR="tomorrow"
    fi

    log "  $BRICKFOLDER/p$(printf '%03d' "$N") (brick=$BRICK, raw=${SRC_GB}GB → $JOBFLAVOUR): submitting full-chain job"
    if ( cd "$PIPE_DIR" && condor_submit \
          -a BRICK="$BRICK" \
          -a BRICK_DIR="$BRICK_DIR" \
          -a PLATENUMBER="$N" \
          -a IN_FILE="$SRC" \
          -a LOG_DIR="${BRICK_DIR}/log" \
          -a JOBFLAVOUR="$JOBFLAVOUR" \
          "$SUBMIT_FILE" ); then
      touch "$MARKER"
    else
      log "  $BRICKFOLDER/$DIRNAME: condor_submit failed; will retry"
    fi
  done

done < <(
  for _base in "${BRICKS_SEARCH_ROOTS[@]}"; do
    [ -d "$_base" ] || { log "  WARNING: search root not accessible: $_base"; continue; }
    find "$_base" -mindepth 2 -maxdepth 4 -type d -name 'b[0-9]*' -print0 2>/dev/null
  done
)

log "===== watch_mosaic done ====="
