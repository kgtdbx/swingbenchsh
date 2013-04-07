

dt=`date +'%Y_%m_%d_%H:%M:%S'`
dt=`date +'%Y_%m_%d_%H%M'`
dir="run$dt"
mkdir $dir
mv *out *awr *lst  $dir
