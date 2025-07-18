BRICKID=$1
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
mkdir report_trk
for CELL in $(seq 0 323); do
  xcell=$(((CELL % 18 + 1) * 10))
  ycell=$(((CELL / 18 + 1) * 10))
  xpos=$((xcell * 1000))
  ypos=$((ycell * 1000))
  folder=cell_${xcell}_${ycell}

  if [ ! -d "$folder" ]; then
    echo "create new folder $folder"
    cp -r cell_template $folder
    cd $folder/$BRICKFOLDER
  else
    echo "$folder already exist"
    cd $folder/$BRICKFOLDER
  fi

  sed -i "s/XPOS/$xpos/;s/YPOS/$ypos/" viewsideal.rootrc
  sed -i "s/XPOS/$xpos/;s/YPOS/$ypos/" track_realign.rootrc
  sed -i "s/XPOS/$xpos/;s/YPOS/$ypos/" track_unbend.rootrc
  sed -i "s/XPOS/$xpos/;s/YPOS/$ypos/" track_full.rootrc
  
  cd ../../
done
