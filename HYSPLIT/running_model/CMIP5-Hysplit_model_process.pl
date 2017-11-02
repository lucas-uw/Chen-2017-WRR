#!/usr/bin/env perl

$model = shift; #"CNRM-CM5";
$period = shift; # "hist" or "future"
$height = shift // 1000;  # for now use 1000
$sevent = 1;
$eevent = 100;

$headindex = $eevent;
$tailindex = $eevent-$sevent+1;
#print "head -$headindex $hu8_list_file | tail -$tailindex |\n";
#exit;

if($model eq "") {
  print "CMIP5-Hysplit_model_process.pl       Running Hysplit with CMIP5 data\n";
  print "  author:  Xiaodong Chen (xiaodc\@uw.edu)\n";
  print "  Use:  CMIP5-Hysplit_model_process.pl <model> <period> <height>\n";
  print "        <model>     CMIP5 model. Fow now: CMCC-CM; CNRM-CM5; ACCESS1-0; GFDL-ESM2G; MPI-ESM-LR\n";
  print "        <period>    study period. For now:  hist (1970-2016); future (2050-2099)\n";
  print "        <height>    release height in Hysplit (unit: m). Default is 1000m\n";
  exit;
}

if($period eq "hist") {
  $syear = 1970;
  $eyear = 2016;
}
if($period eq "future") {
  $syear = 2050;
  $eyear = 2099;
}


$hu8_list_file = "/raid2/xiaodong.chen/lulcc/ref_data/HU8_PNW_list.txt";
#$hu8_list_file = "HU8_PNW_list.1lines.txt";
#$hu8_list_file = "HU8_PNW_list.exclude17110020.txt";


open(IN, $hu8_list_file) or die "$0: ERROR: cannot open hu8_list_file $hu8_list_file for reading\n";
foreach $huid(<IN>) {
  chomp $huid;
  print "Working in HU $huid\n";
  $file = "/raid/xiaodong.chen/lulcc/data/sim.proj/hysplit/input_info/top200/$model/$period/$huid.$model.$period.txt";

  $cmd = "mkdir -p /raid/xiaodong.chen/lulcc/data/sim.proj/hysplit/results/$model/$period/H$height/$huid";
  #print "$cmd\n";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";

  $event_count = $sevent;
  open(REF, "head -$headindex $file | tail -$tailindex |") or die "$0: ERROR: cannot open file $file for reading\n";
  foreach $line(<REF>) {
    print "  Event #$event_count\n";

    # open output file, one file for each event
    $outfile = "/raid/xiaodong.chen/lulcc/data/sim.proj/hysplit/results/$model/$period/H$height/$huid/$huid.$model.$period.event$event_count.txt";
    open(OUT, ">$outfile" ) or die "$0: ERROR: cannot open for writing\n";

    chomp $line;
    s/^\s+//, $line;
    @fields_ref = split/\s+/, $line;
    ($indext, $year, $month, $day, $lat, $lon, $P3day) = split/\s+/, $line;
    #print "year=$year, month=$month, day=$day, lat=$lat, lon=$lon\n";

    # prepare CONTROL file
    $y2y = substr($year,2,2);
    $m2m = sprintf "%02d", $month;
    $d2d = sprintf "%02d", $day;
    $y4y = $year;
    $mm = $month;
    $cmd = "sed 's/<Y2Y>/$y2y/' /usr1/xiaodong.chen/lulcc/models/hysplit/cmip5/CONTROL.template | sed 's/<M2M>/$m2m/' | sed 's/<D2D>/$d2d/' | sed 's/<LAT>/$lat/' | sed 's/<LON>/$lon/' | sed 's/<Y4Y>/$y4y/' | sed 's/<MM>/$mm/' | sed 's/<MODEL>/$model/' | sed 's/<HEIGHT>/$height/'  > /usr1/xiaodong.chen/lulcc/models/hysplit/cmip5/CONTROL.$model";
    #print "$cmd\n";
    (system($cmd)==0) or die "$0: ERRO: $cmd failed\n";

    ## run Hysplit model
    $cmd = "cd /usr1/xiaodong.chen/lulcc/models/hysplit/cmip5;hyts_std $model > /dev/null";
    #print "$cmd\n";
    (system($cmd)==0) or die "$0: ERRO: $cmd failed\n";


    ## collect output
    $results_file = "/usr1/xiaodong.chen/lulcc/models/hysplit/cmip5/output/$model/$model\_1point";
    open(RES, $results_file) or die "$0: ERROR: cannot open results_file $results_file for reading\n";
    $count=0;
    foreach $results(<RES>) {
      if($count>=5) {
        chomp $results;
        s/^\s+//, $results;
        @fields = split/\s+/, $results;
        if($fields[11]<0) {
          printf OUT "%s%02d  %2d  %2d  %2d   %.5f  %.5f   %.2f\n", substr($year,0,2), $fields[3],$fields[4],$fields[5],$fields[6],$fields[10],$fields[11]+360,$fields[12];
        }
        else {
          printf OUT "%s%02d  %2d  %2d  %2d   %.5f  %.5f   %.2f\n", substr($year,0,2), $fields[3],$fields[4],$fields[5],$fields[6],$fields[10],$fields[11],$fields[12];
        }
      }
      $count++;
    }
    close(OUT);


    # clean hysplit dir
    $cmd = "cd /usr1/xiaodong.chen/lulcc/models/hysplit/cmip5;rm CONTROL.$model MESSAGE.$model WARNING.$model output/$model/$model\_1point";
    #print "$cmd\n";
    (system($cmd)==0) or die "$0: ERRO: $cmd failed\n";
    
    $event_count++;

    close(RES);
  }

  close(REF);
  
}
close(IN);
