BRICKID=$1
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"

script_dir=/afs/cern.ch/work/f/falicant/public/emu_reconstruction
target_dir=$BRICKFOLDER

mkdir $target_dir/
mkdir $target_dir/AFF
mkdir $target_dir/report/tal
mkdir $target_dir/report/mos

cp $script_dir/create_link.sh $target_dir
cp $script_dir/scanset.sh $target_dir
cp $script_dir/1.mosaic/viewsideal.rootrc $target_dir
cp $script_dir/1.mosaic/viewsideal.sh $target_dir
cp $script_dir/1.mosaic/check_mos.C $target_dir
cp $script_dir/2.tag/mostag.sh $target_dir
cp $script_dir/2.tag/tagalignplate.sh $target_dir
cp $script_dir/2.tag/tagalign.sh $target_dir
cp $script_dir/2.tag/tagalign.rootrc $target_dir
cp $script_dir/2.tag/check_al.C $target_dir
cd $target_dir