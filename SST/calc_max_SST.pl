#!/usr/bin/env perl

$model = shift;

$rootdir = "/raid/xiaodong.chen/lulcc/data/sim.proj/CMIP5_orig/SST";

$indir = "$rootdir/$model/for_max_calc";
$outdir = "$rootdir/$model/annual_max";

open(OUT1,">cmd.calc_annual_max.csh") or die "$0: ERROR: cannot open OUT1 cmd.calc_annual_max.csh for writing\n";
open(OUT2,">cmd.calc_period_max.csh") or die "$0: ERROR: cannot open OUT2 cmd.calc_period_max.csh for writing\n";

$cmd = "mkdir $outdir";
print OUT1 "$cmd\n";
#(system($cmd)==0) or die "$0: ERROR: $cmd failed\n";


print OUT2 "ncrcat ";
for($year=1969; $year<=2016; $year++) {
  $infile = "$indir/tos.$model.$year.2x2box.nc";
  $outfile = "$outdir/tos.$model.$year.2x2box.max.nc";
  $cmd = "cdo timmax $infile $outfile";
  print OUT1 "$cmd\n";
  #(system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
  print OUT2 "$outfile "; 
}
print OUT2 "$outdir/tos.$model.2x2box.max_by_year.1969-2016.nc\n";
print OUT2 "cdo timmax $outdir/tos.$model.2x2box.max_by_year.1969-2016.nc $outdir/tos.$model.2x2box.max.1969-2016.tmp1.nc\n";
print OUT2 "ncwa -a time $outdir/tos.$model.2x2box.max.1969-2016.tmp1.nc $rootdir/$model/tos.$model.2x2box.max.1969-2016.nc\n";
print OUT2 "rm $outdir/tos.$model.2x2box.max.1969-2016.tmp1.nc\n";

print OUT2 "ncrcat ";
for($year=2049; $year<=2099; $year++) {
  $infile = "$indir/tos.$model.$year.2x2box.nc";
  $outfile = "$outdir/tos.$model.$year.2x2box.max.nc";
  $cmd = "cdo timmax $infile $outfile";
  print OUT1 "$cmd\n";
  #(system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
  print OUT2 "$outfile "; 
}
print OUT2 "$outdir/tos.$model.2x2box.max_by_year.2049-2099.nc\n";
print OUT2 "cdo timmax $outdir/tos.$model.2x2box.max_by_year.2049-2099.nc $outdir/tos.$model.2x2box.max.2049-2099.tmp1.nc\n";
print OUT2 "ncwa -a time $outdir/tos.$model.2x2box.max.2049-2099.tmp1.nc $rootdir/$model/tos.$model.2x2box.max.2049-2099.nc\n";
print OUT2 "rm $outdir/tos.$model.2x2box.max.2049-2099.tmp1.nc\n";

#print OUT2 "rm -r $outdir\n";
close(OUT1);
close(OUT2);
