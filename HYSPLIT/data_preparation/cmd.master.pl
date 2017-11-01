#!/usr/bin/env perl

##----------------------------------------------
# before running this script, first process the 
# first year (i.e. 1969 and 2049) to get monthly 
# nc files.
# see wrap_process_CMIP5_to_grib.first.pl
##----------------------------------------------

#$model = "CMCC-CM";
#$sciptstr = "CMCC-CM.CNRM-CM5";

#$model = "CNRM-CM5";
#$sciptstr = "CMCC-CM.CNRM-CM5";

#$model = "ACCESS1-0";
#$scriptstr = $model;

#$model = "GFDL-ESM2G";
#$scriptstr = $model;

#$model = "MPI-ESM-LR";
#$scriptstr = $model;


# historical
$cmd = "wrap_process_CMIP5_to_grib.$scriptstr.first.pl $model 1969 > logs/$model/log.$model.1969.txt";
print "$cmd\n";
(system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
for($year=1970; $year<=2016; $year++) {
  $cmd = "wrap_process_CMIP5_to_grib.$scriptstr.pl $model $year > logs/$model/log.$model.$year.txt";
  print "$cmd\n";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
}


# future
$cmd = "wrap_process_CMIP5_to_grib.$scriptstr.first.pl $model 2049 > logs/$model/log.$model.2049.txt";
print "$cmd\n";
(system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
for($year=2050; $year<=2099; $year++) {
  $cmd = "wrap_process_CMIP5_to_grib.$scriptstr.pl $model $year > logs/$model/log.$model.$year.txt";
  print "$cmd\n";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
}
