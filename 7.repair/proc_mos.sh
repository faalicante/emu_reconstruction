export brick=$1
do_vsa=1
do_plate=1
do_align=1

plates=(28 31 35)
file="viewsideal.rootrc"

mkdir out

if [ $do_vsa == 1 ]; then
  
    makescanset -set=${brick}.0.0.0 -dz=-1350 -from_plate=57 -to_plate=1 -dzbase=195 > out/${brick}.0.0.0.mks_pl.txt 2>&1
    
    for p in "${plates[@]}"; do
        sed -i '1c\fedra.vsa.DoImageCorr:                   0' "$file"
        mapfile -t new_aff < <(
            echo vsa0 ${brick}.${p}.0.0 >&2
            viewsideal -id=${brick}.${p}.0.0 -v=1 > "out/${brick}.${p}.0.0.vsa0.txt" 2>&1
            awk '/EdbFragmentAlignment::AlignFragment: apply/ {print $3, $4, $5, $6}' "out/${brick}.${p}.0.0.vsa0.txt"
        )
        side1="${new_aff[0]}  0 0"
        side2="${new_aff[1]}  0 0"
        echo "Updating alignment for plate ${p}:"
        echo $side1
        echo $side2
          
        awk -v side1="$side1" -v side2="$side2" '
        NR == 1 {print "fedra.vsa.DoImageCorr:                   1"; next}
        NR == 2 {print "fedra.vsa.ImageCorrSide1:                " side1; next}
        NR == 3 {print "fedra.vsa.ImageCorrSide2:                " side2; next}
        { print }
        ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"

        echo vsa1 ${brick}.${p}.0.0 >&2
        viewsideal -id=${brick}.${p}.0.0 -v=1 > "out/${brick}.${p}.0.0.vsa1.txt" 2>&1
    done
fi

if [ $do_plate == 1 ]; then
    # printf '%s\n' "${plates[@]}" | xargs -i -P 8 bash -c 'echo vsa ${brick}.{}.0.0 && /usr/bin/time -v viewsideal -id=${brick}.{}.0.0 -v=1 > out/${brick}.{}.0.0.vsa.txt 2>&1'
    printf '%s\n' "${plates[@]}" | xargs -i -P 8 bash -c 'echo ab0 ${brick}.{}.0.0 && /usr/bin/time -v mosalignbeam -id=${brick}.{}.0.0 -v=1 > out/${brick}.{}.0.0.ab0.txt 2>&1'
    printf '%s\n' "${plates[@]}" | xargs -i -P 8 bash -c 'echo mln ${brick}.{}.0.0 && /usr/bin/time -v moslink -id=${brick}.{}.0.0 -v=2 > out/${brick}.{}.0.0.mln.txt 2>&1'
    printf '%s\n' "${plates[@]}" | xargs -i -P 8 bash -c 'echo mlm ${brick}.{}.0.0 && /usr/bin/time -v moslink -id=${brick}.{}.0.0 -v=2 -merge > out/${brick}.{}.0.0.mlm.txt 2>&1'
fi

if [ $do_align == 1 ]; then

    brick6=$(printf "b%06d" "$brick")
    for p in "${plates[@]}"; do
        p_next=$((p + 1))
        p_prev=$((p - 1))
        echo "cp ../../cell_template/${brick6}/AFF/${brick}.${p}.0.0_${brick}.${p_prev}.0.0.aff.par ./AFF"
        echo "cp ../../cell_template/${brick6}/AFF/${brick}.${p_next}.0.0_${brick}.${p}.0.0.aff.par ./AFF"
        cp ../../cell_template/${brick6}/AFF/${brick}.${p}.0.0_${brick}.${p_prev}.0.0.aff.par ./AFF
        cp ../../cell_template/${brick6}/AFF/${brick}.${p_next}.0.0_${brick}.${p}.0.0.aff.par ./AFF
    done

    makescanset -set=${brick}.0.0.0 -dz=-1350 -from_plate=57 -to_plate=1 -dzbase=195 > out/${brick}.0.0.0.mks_al.txt 2>&1
#     cp alignR3.rootrc align.rootrc
#     printf '%s\n' "${plates[@]}" | awk '{print $1; print $1 - 1}' | sort -n -u | xargs -i -P 8 bash -c \
# 	'export al2f="out/${brick}.{}.0.0.al1.txt";  echo ${al2f}; date > ${al2f}; cat align.rootrc >> ${al2f}; \
#  . ./alignplate.sh ${brick} {} 1 >> ${al2f} 2>&1'
#     makescanset -set=${brick}.0.0.0 -from_plate=57 -to_plate=1 -dzbase=195 > out/${brick}.0.0.0.mks_R2.txt 2>&1

    cp align_2.rootrc align.rootrc
    printf '%s\n' "${plates[@]}" | awk '{print $1; print $1 - 1}' | sort -n -u | xargs -i -P 8 bash -c \
	'export al2f="out/${brick}.{}.0.0.al2.txt";  echo ${al2f}; date > ${al2f}; cat align.rootrc >> ${al2f}; \
 . ./alignplate.sh ${brick} {} 1 >> ${al2f} 2>&1'
    makescanset -set=${brick}.0.0.0 -from_plate=57 -to_plate=1 -dzbase=195 > out/${brick}.0.0.0.mks_R2.txt 2>&1

    cp align_3.rootrc align.rootrc
    printf '%s\n' "${plates[@]}" | awk '{print $1; print $1 - 1}' | sort -n -u | xargs -i -P 8 bash -c \
	'export al2f="out/${brick}.{}.0.0.al3.txt";  echo ${al2f}; date > ${al2f}; cat align.rootrc >> ${al2f}; \
 . ./alignplate.sh ${brick} {} 1 >> ${al2f} 2>&1'
    makescanset -set=${brick}.0.0.0 -from_plate=57 -to_plate=1 -dzbase=195 > out/${brick}.0.0.0.mks_R2.txt 2>&1

fi