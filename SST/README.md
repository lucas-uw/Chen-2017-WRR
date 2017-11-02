### The scripts in this directory handles the SST data (OISST and CMIP5)

## 0. cmd.split_year.csh
This script call the split_year.csh or split_year.no_leap.csh, which split the original CMIP5 SST to yearly files. If your computer is comfortable to the size of the original files, you may skip this step.

## 1. wrap.process\_SST(.OISST).pl
This script calls the CMIP5\_SST\_fields.moving\_average.regular\_latlon.py script, and apply the 2x2 degree box to the SST fields.

## 2. handle\_GFDL\_sst.pl
This script clean the GFDL files for these leap years, so the next step (adding Feb 29) is made easier.

## 3. handle\_leap\_data.pl
Since GFDL data is in a quite different calendar format than other CMIP5 models used here, the Feb29 data needs to be filled using Feb 28 data during the leap years.Then the files are copied back and used to replace the original CMIP5 files (this needs to be done mannually just to be safe).

## 4. calc\_max\_SST.pl
By running this script, you will get two shell scripts. One is to generate the annual maximum SST, another is to derive the period maximum SST (i.e., in our case 1970-2016, 2050-2099).