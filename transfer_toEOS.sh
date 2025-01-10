#!/bin/sh

localdir=/drives/d/SND/RUN2/RUN2_W1_B3
remotedir=/eos/experiment/sndlhc/emulsionData/2022/CERN/SND_mic2/RUN2/
currdate=$(date +"%Y%m%d_%s")
cryptedfile=/drives/d/snd2cern.txt.gpg

# Decrypt the encrypted file
rsync -av --partial --inplace --append-verify --progress --rsh="/usr/bin/sshpass -p`cat /drives/d/snd2cern.txt` ssh -o StrictHostKeyChecking=no" ${localdir} --exclude '*.obx*' snd2cern@lxplus.cern.ch:${remotedir}

