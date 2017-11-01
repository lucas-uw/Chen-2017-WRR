#!/usr/bin/env perl

$model = shift;
$year = shift;
$toolsdir = "/usr1/xiaodong.chen/lulcc/tools/cmip_tools/hysplit";
$rootdir = "/raid2/xiaodong.chen/lulcc/CMIP5";

$ECMWF_gridfile = "/usr1/xiaodong.chen/lulcc/tools/cmip_tools/hysplit/gridfile_ERA_Interim_Pacific";

for($month=1; $month<=12; $month++) {
  print "Processing $year $month\n";

  # clip and remap original CMIP5
  $cmd = "$toolsdir/clip_remap_CMIP5_data.pl $model $year $month $rootdir $ECMWF_gridfile";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";

  # assemble into one big file
  $cmd = "$toolsdir/nc2bignc.CMCC-CM.CNRM-CM5.py $model $year $month $rootdir/$model/remap_by_month day.$model $rootdir/$model/monthly_ext";
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
 
  $cmd = "cd /usr1/xiaodong.chen/lulcc/models/hysplit/xc;grib2arl -i$model.$year.$month.12hr.ext.grib1 -cECMWF_ref/ERA_invariant.Pacific.grib";
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
