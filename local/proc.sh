typeset -i brick=21
export brick

makescanset -set=${brick}.0.0.0 -dz=-1350 -from_plate=57 -to_plate=1 -dzbase=195
seq 11 21 | xargs -i -P 11 bash -c 'echo vsa ${brick}.{}.0.0 && /usr/bin/time -v viewsideal   -id=${brick}.{}.0.0 -v=1 > out/${brick}.{}.0.0.vsa.txt 2>&1'
seq 11 21 | xargs -i -P 11 bash -c 'echo ab0 ${brick}.{}.0.0 && /usr/bin/time -v mosalignbeam -id=${brick}.{}.0.0 -v=2 > out/${brick}.{}.0.0.ab0.txt 2>&1'
seq 1 21 | xargs -i -P 11 bash -c 'echo tag ${brick}.{}.0.0 && /usr/bin/time -v mostag -id=${brick}.{}.0.0 -v=2 > out/${brick}.{}.0.0.tag.txt 2>&1'
seq 1 20 | xargs -i -P 10 bash -c 'echo tagalign ${brick}.{}.0.0 && . ./tagalign.sh ${brick} {} > out/${brick}.{}.0.0.tal.txt'