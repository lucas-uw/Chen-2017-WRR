#!/usr/bin/env perl

$model = shift;
$year = shift;
$toolsdir = "/usr1/xiaodong.chen/lulcc/tools/cmip_tools/hysplit";
$rootdir = "/raid2/xiaodong.chen/lulcc/CMIP5";


#for($month=12; $month<=12; $month++) {
#for($month=1; $month<=1; $month++) {
for($month=1; $month<=12; $month++) {
  print "Processing $year $month\n";

  # clip and remap original CMIP5
  $cmd = "$toolsdir/$model/clip_CMIP5_data.pl $model $year $month $rootdir";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";

  # assemble into one big file
  $cmd = "$toolsdir/nc2bignc.$model.py $model $year $month $rootdir/$model/remap_by_month day.$model $rootdir/$model/monthly_ext";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";

  # convert to grib
  $cmd = "cdo -f grb -copy $rootdir/$model/monthly_ext/$model.$year.$month.12hr.ext.nc $rootdir/$model/monthly_ext/$model.$year.$month.12hr.ext.grib1";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";

  $cmd = "rm $rootdir/$model/monthly_ext/$model.$year.$month.12hr.ext.nc";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
  
  ## Hysplit
  $cmd = "cd /usr1/xiaodong.chen/lulcc/models/hysplit/xc;ln -s /raid2/xiaodong.chen/lulcc/CMIP5/$model/monthly_ext/$model.$year.$month.12hr.ext.grib1 .";
  print "$cmd\n";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
 
  $cmd = "cd /usr1/xiaodong.chen/lulcc/models/hysplit/xc;grib2arl -i$model.$year.$month.12hr.ext.grib1 -cECMWF_ref/MPI-ESM-LR_orog.grib";
  print "$cmd\n";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
 
  $cmd = "cd /usr1/xiaodong.chen/lulcc/models/hysplit/xc;mv DATA.ARL /raid2/xiaodong.chen/lulcc/CMIP5/$model/ARL/$model.$year.$month.ARL";
  print "$cmd\n";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";

  $cmd = "cd /usr1/xiaodong.chen/lulcc/models/hysplit/xc;rm $model.$year.$month.12hr.ext.grib1";
  print "$cmd\n";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";

  $cmd = "rm $rootdir/$model/monthly_ext/$model.$year.$month.12hr.ext.grib1";
  print "$cmd\n";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
}
