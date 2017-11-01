# HYSPLIT input forcing preparation

Use the tools in this directory to prepare the HYSPLIT input data (i.e., *.ARL files)

1. Download CMIP5 data
2. disaggragate the data into one file for each variable and each month, in the name of "ta.day.CMCC-CM.2000.01.nc" format.
```sh
$ ncks -d time,0,364 ua_day_ACCESS1-0_historical_r1i1p1_19950101-19991231.nc  /raid2/xiaodong.chen/lulcc/CMIP5/ACCESS1-0/orig_global/ua_day_ACCESS1-0_historical_r1i1p1_19950101-19951231.nc
$ ncks -d time,334,364 /raid2/xiaodong.chen/lulcc/CMIP5/ACCESS1-0/orig_global/ua_day_ACCESS1-0_historical_r1i1p1_19950101-19951231.nc /raid2/xiaodong.chen/lulcc/CMIP5/ACCESS1-0/remap_by_month/ua.day.ACCESS1-0.1995.12.nc
```

3. Run cmd.master.pl script, and choose the model name as well as the corresponding scriptstr. For MPI-ESM-LR, the clip_remap_CMIP5_data.pl may need some modification (data availability issue). See this script for details.

## Script logic:
cmd.master.pl will call wrap\_process_CMIP5_to_grib.\*.pl automatically
wrap\_process_CMIP5_to_grib.\*.pl will run nc2bignc.\* script automatically.
