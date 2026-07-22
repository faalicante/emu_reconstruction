#!/bin/bash

export EOSSHIP=root://eospublic.cern.ch/

RUN=$2
BRICKID=$3
BRICKFOLDER=$4
PLATENUMBER=$5
PLATEFOLDER=$6
EXP_PRE=$7
EXP_DIR=$EXP_PRE/RUN$RUN/$BRICKFOLDER

echo "Set up SND environment"
SNDBUILD_DIR=/afs/cern.ch/user/s/snd2cern/public/SNDBUILD/sw
source /cvmfs/sndlhc.cern.ch/SNDLHC-2025/Oct7/setUp.sh
eval `alienv load -w $SNDBUILD_DIR --no-refresh sndsw/latest`
echo "Loading FEDRA"
source /afs/cern.ch/user/s/snd2cern/public/fedra/setup_new.sh

export LD_PRELOAD=/cvmfs/sndlhc.cern.ch/SNDLHC-2025/Oct7/sw/slc9_x86-64/XRootD/latest/lib/libXrdPosixPreload.so
export XROOTD_VMP=eospublic.cern.ch:/eos=/eos

# === OMP override: use optimized libraries ===
# NOTE: Condor batch nodes don't have /eos FUSE mount.  The XRD posix preload
# intercepts open() but NOT openat(), and ld-linux (glibc 2.28+) uses openat()
# to resolve LD_LIBRARY_PATH.  So the dynamic linker cannot load .so files
# from /eos paths.  We must xrdcp them to a local filesystem first.
OMP_EOS_SRC=root://eospublic.cern.ch//eos/experiment/sndlhc/users/vacharit/fedra-perf/profiling_test/build_omp/lib
OMP_LIB_DIR=/tmp/fedra_omp_lib_$$
mkdir -p $OMP_LIB_DIR
echo "Copying OMP libraries to $OMP_LIB_DIR ..."
xrdcp -f $OMP_EOS_SRC/libMosaic.so    $OMP_LIB_DIR/
xrdcp -f $OMP_EOS_SRC/libAlignment.so $OMP_LIB_DIR/
# Do NOT export LD_LIBRARY_PATH — ROOT 6 auto-discovers .pcm files in LD_LIBRARY_PATH,
# causing TFile::Open() to crash on false zombie errors. Use inline LD_PRELOAD instead.
export LD_PRELOAD="$OMP_LIB_DIR/libMosaic.so:$OMP_LIB_DIR/libAlignment.so"

# === Detect actual resources (CPUs + RAM) ===
# nproc: always correct — reflects Condor cgroup CPU limit (can exceed request_cpus)
# $_CONDOR_MACHINE_AD: slot's actual allocated memory in MB (can exceed request_memory)
# Condor kills at 2× request_memory, so we have headroom beyond what the slot reports.
CPUS=$(nproc)
if [ -f "$_CONDOR_MACHINE_AD" ]; then
  RAM_MB=$(awk '/^Memory =/ {print $3}' "$_CONDOR_MACHINE_AD")
  RAM_GB=$(echo "scale=1; $RAM_MB / 1024" | bc)
  echo "Condor slot: ${CPUS} CPUs, ${RAM_GB} GB RAM"
else
  RAM_GB=$(awk '/MemTotal/ {printf "%.0f", $2/1048576}' /proc/meminfo)
  echo "System: ${CPUS} CPUs, ${RAM_GB} GB RAM"
fi

export OMP_NUM_THREADS=$CPUS
export OMP_PROC_BIND=close
export OMP_WAIT_POLICY=passive
# FEDRA_OMP_BATCH is computed after xrdcp (depends on plate size)
# --- Diagnostics ---
echo "OMP env: THREADS=$OMP_NUM_THREADS"
ls -l $OMP_LIB_DIR/

MAIN_DIR=$PWD
cd $MAIN_DIR
MY_DIR=$PLATENUMBER/$BRICKFOLDER
mkdir -p -v ./$MY_DIR/$PLATEFOLDER
cd $MY_DIR

# Copy raw data to local scratch (faster than network symlink for OMP pre-read)
xrdcp -f root://eospublic.cern.ch/$EXP_DIR/$PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.raw.root ./$PLATEFOLDER/

# === Batch size ===
# batch = how many fragments to pre-read and align per round
# Default: batch = CPUS (1 fragment per thread — safe, full parallelism)
# Override: set FEDRA_OMP_BATCH env var before this script, or edit below
# More batches per side = more I/O passes but less memory
RAW_BYTES=$(stat --format='%s' ./$PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.raw.root)
RAW_GB=$(echo "scale=1; $RAW_BYTES / 1073741824" | bc)
if [ -z "$FEDRA_OMP_BATCH" ]; then
  # batch = 2*CPUS: enables schedule(dynamic,1) to actually work.
  # With batch=CPUS, each thread gets exactly 1 fragment → no work stealing.
  # With batch=2*CPUS, each thread processes ~2 fragments dynamically,
  # allowing fast threads to steal work from slow ones → better load balance.
  # RSS per thread: ~1-2 GB, well within slot memory (3 GB/CPU × CPUS).
  # Per-fragment expansion is 1.15-1.44x observed, so 2*CPUS keeps RSS safe.
  FEDRA_OMP_BATCH=$((CPUS * 2))
fi
export FEDRA_OMP_BATCH
echo "Batch: $FEDRA_OMP_BATCH frags/round (raw=${RAW_GB}GB, RAM=${RAM_GB}GB, CPUs=${CPUS})"

ln -s $EXP_DIR/$BRICKFOLDER.0.0.0.set.root .
ln -s $EXP_DIR/viewsideal.sh .
ln -s $EXP_DIR/viewsideal.rootrc ./viewsideal.rootrc
ln -s $EXP_DIR/mostag.sh .

echo "viewsideal $BRICKID.$PLATENUMBER.0.0"
echo "Library check: $(ldd $(which viewsideal) 2>/dev/null | grep -i mosaic)"
source viewsideal.sh $BRICKID $PLATENUMBER

echo "mostag $BRICKID.$PLATENUMBER.0.0"
source mostag.sh $BRICKID $PLATENUMBER

mv $PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.mos.root $MAIN_DIR/
mv $PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.tag.root $MAIN_DIR/

# Cleanup local OMP libraries
rm -rf $OMP_LIB_DIR
