#!/usr/bin/env perl

# This script is meant for GFDL-ESM2G data, which has no Feb29 by default.
# So we copy Feb28 data as Feb29.

$syear = 1969;
$eyear = 2099;
$origdir = "/raid/xiaodong.chen/lulcc/data/sim.proj/CMIP5_orig/SST/GFDL-ESM2G";
$tmpdir = "$origdir/tmp";
$bakdir = "$origdir/bak";

for($year=$syear; $year<=$eyear; $year++) {
  if($year % 400 == 0 || ($year%4==0 && $year%100!=0)) {
    $infile = "tos.GFDL-ESM2G.$year.2x2box.nc";
   
    if(-e "$origdir/$infile") { 
      $cmd = "cp $origdir/$infile $bakdir/tos.GFDL-ESM2G.$year.2x2box.no_leap.nc";
      print "$cmd\n";
      $cmd = "mv $origdir/$infile $tmpdir/tos.$year.orig.nc";
      print "$cmd\n";
      $cmd = "ncatted -a bounds,time,d,, $tmpdir/tos.$year.orig.nc";
      print "$cmd\n";
      $cmd = "ncks -v lat,lon,tos,time $tmpdir/tos.$year.orig.nc $tmpdir/tmp1.nc";
      print "$cmd\n";
      $cmd = "cdo -a setcalendar,standard $tmpdir/tmp1.nc $tmpdir/tmp2.nc";
      print "$cmd\n";
      $cmd = "cdo -setmon,2 -setday,29 -selday,28 -selmon,2 $tmpdir/tmp2.nc $tmpdir/feb29.nc";
      print "$cmd\n";
      $cmd = "cdo -mergetime $tmpdir/tmp2.nc $tmpdir/feb29.nc $tmpdir/tos.GFDL-ESM2G.$year.2x2box.nc";
      print "$cmd\n";
      $cmd = "rm $tmpdir/tos.$year.orig.nc $tmpdir/tmp1.nc $tmpdir/tmp2.nc $tmpdir/feb29.nc";
      print "$cmd\n";
    }
  }
}
