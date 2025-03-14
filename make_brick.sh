BRICKID=$1
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"

script_dir=/afs/cern.ch/work/f/falicant/public/emu_reconstruction
target_dir=$BRICKFOLDER

mkdir -p $target_dir/
mkdir -p $target_dir/out
mkdir -p $target_dir/AFF

cp $script_dir/create_link.sh $target_dir
cp $script_dir/scanset.sh $target_dir
cp $script_dir/1.mosaic/viewsideal.rootrc $target_dir
cp $script_dir/1.mosaic/viewsideal.sh $target_dir
cp $script_dir/2.beam/mosalignbeam.sh $target_dir
cp $script_dir/3.tag/mostag.sh $target_dir
cp $script_dir/3.tag/tagtra.sh $target_dir
cp $script_dir/3.tag/tagalign.sh $target_dir
cd $target_dir