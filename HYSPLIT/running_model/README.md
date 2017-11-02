# Running HYSPLIT model

The three scripts are to be used in the following order:

## prepare\_hysplit\_info.py

From the downscaled CMIP5 precipitation, this script picks out the top 100 extreme storms at each watershed. The results are to be used as input information to the CMIP5-Hysplit\_model\_process.pl script.

The output is in time order (i.e., from the oldest one to most recent one).

## sort_hysplit_input_info.pl

This script rearranges the top 100 storm information using the 3-day total precipitation (from most severe to less severe).

## CMIP5-Hysplit\_model\_process.pl

running HYSPLIT model and organize the HYSPLIT output into more user-friendly format.

Note: Before running this script, make sure you have the information of the top 100 storms (or whatever storm collection).
