BRICKID=$1
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"

script_dir=/afs/cern.ch/work/f/falicant/public/emu_reconstruction/
template_dir=cells/cell_template/$BRICKFOLDER

mkdir -p $template_dir
mkdir -p $template_dir/report

cp $script_dir/4.cell_proc/make_volume.sh cells/
cp -r AFF $template_dir
cp viewsideal*.rootrc $template_dir
cp $script_dir/1.mosaic/scanset.sh $template_dir
cp $script_dir/1.mosaic/viewsideal.sh $template_dir
cp $script_dir/beam/mosalignbeam.sh $template_dir
cp $script_dir/linking/mos*.sh $template_dir
cp $script_dir/align/alignplate.sh $template_dir
cp $script_dir/align/align_*.rootrc $template_dir
cp $script_dir/tracking/tracking_all.sh $template_dir
cp $script_dir/tracking/*.rootrc $template_dir
for PLATENUMBER in $(seq 1 57);do
    PLATEFOLDER="$(printf "p%0*d" 3 $PLATENUMBER)"
    mkdir $template_dir/$PLATEFOLDER
    cp -a $PLATEFOLDER/$BRICKID.$PLATENUMBER.0.0.raw.root ./$template_dir/$PLATEFOLDER
done
cd $template_dir