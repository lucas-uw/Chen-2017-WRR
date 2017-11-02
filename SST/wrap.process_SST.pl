#!/usr/bin/env perl

$model = shift; # CMCC-CM
$syear = shift;
$eyear = shift;

if($model eq "") {
  print "wrap.process_SST.pl  remap CMIP5 SST to regular lat/lon grids\n";
  print "  wrap.process_SST.pl  <model>  <syear>  <eyear>\n";
  exit;
}

#1. remap to .....remap.nc
#2. cp .....remap.nc to .....2x2avg.nc
#3. run python script, infile=...remap.nc,  outfile=.....2x2avg.nc
#4. remove ....remap.nc and the annual file

for($year=$syear; $year<=$eyear; $year++) {
  print "Processing $year...\n";
  
  # 1. regrid
  $cmd = "cdo remapbil,/usr1/xiaodong.chen/lulcc/tools/cmip_tools/python/sst/gridfile_ERA_Interim_Pacific_05deg /raid/xiaodong.chen/lulcc/data/sim.proj/CMIP5_orig/SST/$model/tos.$model.$year.orig.nc /raid/xiaodong.chen/lulcc/data/sim.proj/CMIP5_orig/SST/$model/tmp.$year.nc";
  print "   regridding\n";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";

  # 2. copy
  $cmd = "cp /raid/xiaodong.chen/lulcc/data/sim.proj/CMIP5_orig/SST/$model/tmp.$year.nc /raid/xiaodong.chen/lulcc/data/sim.proj/CMIP5_orig/SST/$model/tos.$model.$year.2x2box.nc";
  print "   copying\n";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";

  # 3. run python script
  $cmd = "/usr1/xiaodong.chen/lulcc/tools/cmip_tools/python/sst/CMIP5_SST_fields.moving_average.regular_latlon.py /raid/xiaodong.chen/lulcc/data/sim.proj/CMIP5_orig/SST/$model/tmp.$year.nc /raid/xiaodong.chen/lulcc/data/sim.proj/CMIP5_orig/SST/$model/tos.$model.$year.2x2box.nc";
  print "   averaging\n";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";

  # clean
  $cmd = "rm /raid/xiaodong.chen/lulcc/data/sim.proj/CMIP5_orig/SST/$model/tmp.$year.nc";
  print "   cleaning\n";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";

}
