#!/usr/bin/env perl

$model = shift;
$year = shift;
$toolsdir = "/usr1/xiaodong.chen/lulcc/tools/cmip_tools/hysplit";
$rootdir = "/raid2/xiaodong.chen/lulcc/CMIP5";

for($month=12; $month<=12; $month++) {
  print "Processing $year $month\n";

  # clip and remap original CMIP5
  $cmd = "$toolsdir/$model/clip_CMIP5_data.pl $model $year $month $rootdir";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
}
