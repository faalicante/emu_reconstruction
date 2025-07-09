export brick=$1
do_plate=1
do_align=1
do_track=1
do_vertex=0

if [ $do_plate == 1 ]
then
  
    makescanset -set=${brick}.0.0.0 -dz=-1350 -from_plate=57 -to_plate=1 -dzbase=195 > out/${brick}.0.0.0.mks_pl.txt 2>&1
  
    seq 1 57 | xargs -i -P 8 bash -c 'echo vsa ${brick}.{}.0.0 && /usr/bin/time -v viewsideal -id=${brick}.{}.0.0 -v=1 > out/${brick}.{}.0.0.vsa.txt 2>&1'
    seq 1 57 | xargs -i -P 8 bash -c 'echo ab0 ${brick}.{}.0.0 && /usr/bin/time -v mosalignbeam -id=${brick}.{}.0.0 -v=1 > out/${brick}.{}.0.0.ab0.txt 2>&1'
    seq 1 57 | xargs -i -P 8 bash -c 'echo mln ${brick}.{}.0.0 && /usr/bin/time -v moslink -id=${brick}.{}.0.0 -v=2 > out/${brick}.{}.0.0.mln.txt 2>&1'
    seq 1 57 | xargs -i -P 8 bash -c 'echo mlm ${brick}.{}.0.0 && /usr/bin/time -v moslink -id=${brick}.{}.0.0 -v=2 -merge > out/${brick}.{}.0.0.mlm.txt 2>&1'

fi

if [ $do_align == 1 ]
then
    makescanset -set=${brick}.0.0.0 -dz=-1350 -from_plate=57 -to_plate=1 -dzbase=195 > out/${brick}.0.0.0.mks_al.txt 2>&1
    cp alignR2.rootrc align.rootrc
    seq 1 56 | xargs -i -P 8 bash -c \
	'export al2f="out/${brick}.{}.0.0.al2.txt";  echo ${al2f}; date > ${al2f}; cat align.rootrc >> ${al2f}; \
 . ./alignplate.sh ${brick} {} >> ${al2f} 2>&1'
    makescanset -set=${brick}.0.0.0 -from_plate=57 -to_plate=1 -dzbase=195 > out/${brick}.0.0.0.mks_R2.txt 2>&1

    cp alignR1.rootrc align.rootrc
    seq 1 56 | xargs -i -P 8 bash -c \
	'export al1f="out/${brick}.{}.0.0.al1.txt"; echo ${al1f}; date > ${al1f}; cat align.rootrc >> ${al1f}; \
 . ./alignplate.sh ${brick} {} >> ${al1f} 2>&1'
    makescanset -set=${brick}.0.0.0 -from_plate=57 -to_plate=1 -dzbase=195 > out/${brick}.0.0.0.mks_R1.txt 2>&1
fi

if [ $do_track == 1 ]
then
    makescanset -set=${brick}.0.0.0 -from_plate=57 -to_plate=1 -dzbase=195 > out/${brick}.0.0.0.mks_tr.txt 2>&1
    cp track_realign.rootrc track.rootrc
    echo track_realign && /usr/bin/time -v emtra    -set=${brick}.0.0.0 -v=2 -new            > out/track_realign.txt 2>&1;
    cat track.rootrc >> out/track_realign.txt

    cp track_unbend.rootrc track.rootrc
    echo track_unbend1 && /usr/bin/time -v emtra    -set=${brick}.0.0.0 -v=2 -new            > out/track_unbend1.txt 2>&1;
    cat track.rootrc >> out/track_unbend1.txt

    echo unbend1       && /usr/bin/time -v emunbend -set=${brick}.0.0.0 -v=2 -corraff        > out/unbend1.txt 2>&1;
    cat unbend.rootrc >> out/unbend1.txt

    echo track_unbend2 && /usr/bin/time -v emtra    -set=${brick}.0.0.0 -v=2 -new            > out/track_unbend2.txt 2>&1;
    cat track.rootrc >> out/track_unbend2.txt

    echo unbend2       && /usr/bin/time -v emunbend -set=${brick}.0.0.0 -v=2 -alg5g -corraff > out/unbend2.txt 2>&1;
    cat unbend.rootrc >> out/unbend2.txt

    echo track_unbend3 && /usr/bin/time -v emtra    -set=${brick}.0.0.0 -v=2 -new            > out/track_unbend3.txt 2>&1;
    cat track.rootrc >> out/track_unbend3.txt

    echo unbend3       && /usr/bin/time -v emunbend -set=${brick}.0.0.0 -v=2 -corraff        > out/unbend3.txt 2>&1;
    cat unbend.rootrc >> out/unbend4.txt

    cp track_full.rootrc track.rootrc
    echo track_unbend4 && /usr/bin/time -v emtra    -set=${brick}.0.0.0 -v=2 -new            > out/track_unbend4.txt 2>&1;
    cat track.rootrc >> out/track_unbend4.txt

    cp unbend_tree.rootrc unbend.rootrc
    echo unbend4       && /usr/bin/time -v emunbend -set=${brick}.0.0.0 -v=2 -alg5g          > out/unbend4.txt 2>&1;
    cat unbend.rootrc >> out/unbend4.txt
fi

if [ $do_vertex == 1 ]
then
 echo emvertex       && /usr/bin/time -v emvertex -set=${brick}.0.0.0 -v=2         > out/vertex.txt 2>&1 \
        && cat vertex.rootrc >> out/vertex.txt
fi