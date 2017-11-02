#!/usr/bin/env python

# Note the input data to this script is in 0.5deg, so 2x2deg box is 5x5 big in terms of dimension.

import numpy as np
import netCDF4 as nc
import sys

infile = sys.argv[1]
outfile = sys.argv[2]

# define the area size of smoothing
Rb = 2 # deg, so 2x2deg box

ingroup = nc.Dataset(infile, 'r', format='NETCDF4')
orig_sst = ingroup.variables['sst'][:]
lat_matrix = ingroup.variables['lat'][:]
lon_matrix = ingroup.variables['lon'][:]
ingroup.close()

nt, nx, ny = orig_sst.shape

out_sst = np.ones((nt, nx, ny))*1.e+20
for x in np.arange(3,nx-3):
    #print x
    for y in np.arange(3,ny-3):
        if orig_sst.mask[0,x,y]==0:
            out_sst[:,x,y] = np.mean(np.mean(orig_sst[:,(x-Rb):(x+1+Rb),(y-Rb):(y+1+Rb)], axis=2), axis=1) # explanation of Rb:  Rb/2/0.5

outgroup = nc.Dataset(outfile, 'a')
tosvar = outgroup.variables['sst']
tosvar.note = '2x2 box averaged'
tosvar[:] = out_sst
outgroup.close()
