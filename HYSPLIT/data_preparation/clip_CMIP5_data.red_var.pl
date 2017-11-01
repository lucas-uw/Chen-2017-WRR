#!/usr/bin/env perl

$model = shift;
$year = shift;
$month = shift;

$rootdir = "/raid2/xiaodong.chen/lulcc/CMIP5";
@varlist = ('zg','ta','ua','va','wap','tas','uas','vas');

if($year<=2005) {
	$scenario = "historical";
}
else {
	$scenario = "rcp85";
}
@rec1s_normal = (0,0,31,59,90,120,151,181,212,243,273,304,334); # all for ncks, first 0s are to make month work from 1 to 12
@rec2s_normal = (0,30,58,89,119,150,180,211,242,272,303,333,364);
@rec1s_leap = (0,0,31,60,91,121,152,182,213,244,274,305,335);
@rec2s_leap = (0,30,59,90,120,151,181,212,243,273,304,334,365);

$orig_dir = "$rootdir/$model/orig_global";
$out_dir = "$rootdir/$model/remap_by_month";

$yearstr = sprintf "%d", $year;
$monthstr = sprintf "%02d", $month;

if($year % 400 == 0 || ($year%4==0 && $year%100!=0)) {
	@rec1s = @rec1s_leap;
	@rec2s = @rec2s_leap;
}
else {
	@rec1s = @rec1s_normal;
	@rec2s = @rec2s_normal;
}

foreach $var(@varlist) {
	$infile = "$orig_dir/$var\_day_$model\_$scenario\_r1i1p1_${year}0101-${year}1231.nc";
	$tmpfile_month = "$out_dir/$var.day.$model.$year.$month.nc";
	$tmpfile_remap = "$remap_dir/$var.day.$model.$year.$month.nc";

	$cmd = "ncks -d time,@rec1s[$month],@rec2s[$month] $infile $tmpfile_month";
	print "# clipping\n$cmd\n";
	(system($cmd)==0) or die "$0: ERROR: $cmd failed\n";

}
