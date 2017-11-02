#!/usr/bin/env perl

# This script is meant for GFDL-ESM2G data.

$syear = 1969;
$eyear = 2099;
$origdir = "/raid/xiaodong.chen/lulcc/data/sim.proj/CMIP5_orig/SST/GFDL-ESM2G";
$outdir = "$origdir/for_max_calc";

for($year=$syear; $year<=$eyear; $year++) {
  $infile = "tos.GFDL-ESM2G.$year.2x2box.nc";
  if($year % 400 == 0 || ($year%4==0 && $year%100!=0)) {
    $cmd = "cp $origdir/$infile $outdir/";
    print "$cmd\n";
  }
  else {
    if(-e "$origdir/$infile") { 
      $cmd = "cp $origdir/$infile $outdir/tos.$year.tmp.nc";
      print "$cmd\n";
      $cmd = "ncatted -a bounds,time,d,, $outdir/tos.$year.tmp.nc";
      print "$cmd\n";
      $cmd = "ncks -v lat,lon,tos,time $outdir/tos.$year.tmp.nc $outdir/$infile";
      print "$cmd\n";
      $cmd = "rm $outdir/tos.$year.tmp.nc";
      print "$cmd\n";
    }
  }
}
