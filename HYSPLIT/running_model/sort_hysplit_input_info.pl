#!/usr/bin/env perl

$model = shift;

@periods = ("hist","future");

foreach $period(@periods) {
  $indir = "/raid/xiaodong.chen/lulcc/data/sim.proj/hysplit/input_info/top200.in_time_order/$model/$period";
  $outdir = "/raid/xiaodong.chen/lulcc/data/sim.proj/hysplit/input_info/top200/$model/$period";

  $cmd = "mkdir -p $outdir";
  print "$cmd\n";
  #(system($cmd)==0) or die "$0: ERROR: $cmd failed\n";


  opendir(DIR, $indir) or die "$0: ERROR: cannot open indir $indir for reading\n";
  @files = grep/^1/, readdir(DIR);
  closedir(DIR);

  foreach $file(@files) {
    $infile = "$indir/$file";
    $outfile = "$outdir/$file";

    $cmd = "sort -k 7 -n -r $infile > $outfile";
    print "$cmd\n";
    #(system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
  }


}
