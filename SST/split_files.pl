#!/usr/bin/env perl

$syear = shift;
$eyear = shift;
$model = shift;
$infile = shift;
$outdir = shift;

if($syear eq "") {
  print "split_files.pl    Split files into small annual chunks\n";
  print "Use:   split_files.pl <syear> <eyear> <model> <infile> <outdir>\n";
  print "         <syear>  starting year\n";
  print "         <eyear>  end year, just to be the desired last year\n";
  print "         <model>  model name\n";
  print "         <infile>  input file\n";
  print "         <outdir>  output dir\n";
  exit;
}

$sindex = 0;
if($syear % 400 == 0 || ($syear%4==0 && $syear%100!=0)) { # leap year
  $eindex = 365;
}
else {
  $eindex = 364;
}
for($year=$syear; $year<=$eyear; $year++) {
  $outfile = "$outdir/tos.$model.$year.orig.nc";
  $cmd = "ncks -d time,$sindex,$eindex $infile $outfile\n";
  print "Year $year .....\n";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";

  if($year % 400 == 0 || ($year%4==0 && $year%100!=0)) {
    $sindex += 366;
  }
  else {
    $sindex += 365;
  }

  $yearn = $year+1;
  if($yearn % 400 == 0 || ($yearn%4==0 && $yearn%100!=0)) {
    $eindex += 366;
  }
  else {
    $eindex += 365;
  }
}
