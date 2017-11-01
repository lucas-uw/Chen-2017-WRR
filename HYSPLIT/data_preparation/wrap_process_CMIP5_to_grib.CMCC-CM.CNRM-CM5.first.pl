#!/usr/bin/env perl

$model = shift;
$year = shift;
$toolsdir = "/usr1/xiaodong.chen/lulcc/tools/cmip_tools/hysplit";
$rootdir = "/raid2/xiaodong.chen/lulcc/CMIP5";

#$ECMWF_gridfile = "/usr1/xiaodong.chen/lulcc/tools/cmip_tools/hysplit/gridfile_ERA_Interim_NPacific";
$ECMWF_gridfile = "/usr1/xiaodong.chen/lulcc/tools/cmip_tools/hysplit/gridfile_ERA_Interim_Pacific";

for($month=12; $month<=12; $month++) {
  print "Processing $year $month\n";

  # clip and remap original CMIP5
  $cmd = "$toolsdir/clip_remap_CMIP5_data.pl $model $year $month $rootdir $ECMWF_gridfile";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
}
