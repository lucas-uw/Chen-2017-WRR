### The scripts in this directory handles the HYSPLIT output, and get them ready for PMP estimation in HMR57 (i.e., SST-based moisture maximization)


## 1. append\_sst\_to\_hysplit\_results.py

This script appends the SST data (SST during the event, historical max SST, future max SST) to the HYSPLIT results. So the SST-maximization in the following step is made easy.

- Note: There are several hard-coded parameters in the script (mainly as dimension of the SST data). One may need to modify this with SST of different domain.

## 2. collect\_CMIP5-Hysplit\_PMP.needed\_data.\*.py

This script reads in the file produced by the previous step, and find the location that results in the greatest maximization ratio (i.e., max PW(SSTm)/PW(SST)). So in the output, for each event there is just one line (i.e., one location, and this location is used to derive PMP).