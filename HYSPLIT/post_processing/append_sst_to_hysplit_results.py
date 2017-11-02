#!/usr/bin/env python

import numpy as np
import netCDF4 as nc
import scipy.io as sio
import math
import sys

model = sys.argv[1]
period = sys.argv[2]
Hvalue = int(sys.argv[3])  # e.g.  1000

def generate_ext_sst(model, year, month):
    infile = '/raid2/xiaodong.chen/lulcc/CMIP5/'+model+'/tos/tos.day.'+model+'.'+str(year)+'.'+str(month)+'.2x2box.nc'
    rootgroup = nc.Dataset(infile, 'r', format='NETCDF4')
    sst_data2 = rootgroup.variables['tos'][:]
    rootgroup.close()
    
    yearp = year
    monthp = month-1
    if monthp==0:
        monthp=12
        yearp = yearp-1
    infilep = '/raid2/xiaodong.chen/lulcc/CMIP5/'+model+'/tos/tos.day.'+model+'.'+str(yearp)+'.'+str(monthp)+'.2x2box.nc'
    rootgroup = nc.Dataset(infilep, 'r', format='NETCDF4')
    sst_data1 = rootgroup.variables['tos'][-10::,:,:]
    rootgroup.close()
    
    outdata = np.concatenate((sst_data1, sst_data2), axis=0)
    return outdata

# data used to determine the latlon2xy function
#sst_reffile = '/raid2/xiaodong.chen/lulcc/CMIP5/CMCC-CM/tos/tos.day.CMCC-CM.1970.10.2x2box.nc'
#refgroup = nc.Dataset(sst_reffile, 'r', format='NETCDF4')
#sst_lat_array = refgroup.variables['lat'][:]
#sst_lon_array = refgroup.variables['lon'][:]
#refgroup.close()

#print sst_lat_array
#print sst_lon_array


def latlon2xy(lat_value, lon_value):
    x = int((round(lat_value*2)/2+40)*2)
    y = int((round(lon_value*2)/2-80)*2)
    return x,y


hu8listfile = '/raid2/xiaodong.chen/lulcc/ref_data/HU8_PNW_list.mat'
hu8_list = sio.loadmat(hu8listfile)['HU8_PNW_list']

sst_indexfile = '/raid2/xiaodong.chen/lulcc/ref_data/sst_ext_index_default.mat'
sst_index_default = sio.loadmat(sst_indexfile)['default_index']


sst_hist_max_file = '/raid/xiaodong.chen/lulcc/data/sim.proj/CMIP5_orig/SST/'+model+'/tos.'+model+'.2x2box.max.1969-2016.nc'
ingroup = nc.Dataset(sst_hist_max_file, 'r', format='NETCDF4')
sst_max_hist_data = ingroup.variables['tos'][:]
ingroup.close()

sst_future_max_file = '/raid/xiaodong.chen/lulcc/data/sim.proj/CMIP5_orig/SST/'+model+'/tos.'+model+'.2x2box.max.2049-2099.nc'
ingroup = nc.Dataset(sst_future_max_file, 'r', format='NETCDF4')
sst_max_future_data = ingroup.variables['tos'][:]
ingroup.close()


for nn in np.arange(220):
    print nn
    huid = str(hu8_list[nn,0])
    storm_list = '/raid/xiaodong.chen/lulcc/data/sim.proj/hysplit/input_info/top200/'+model+'/'+period+'/'+huid+'.'+model+'.'+period+'.txt'
    storm_infos = np.genfromtxt(storm_list)

    for i in np.arange(100):
        storm_count = i+1
        (index, year, month, day, lat, lon, height) = storm_infos[i,:]
        sst_data = generate_ext_sst(model, int(year), int(month))
        hysplit_file = '/raid/xiaodong.chen/lulcc/data/sim.proj/hysplit/results/'+model+'/'+period+'/H'+str(Hvalue)+'/'+huid+'/'+huid+'.'+model+'.'+period+'.event'+str(storm_count)+'.txt'
        event_data = np.genfromtxt(hysplit_file)
        sst_time_index = sst_index_default + day + 9
    
        outfile = '/raid/xiaodong.chen/lulcc/data/sim.proj/hysplit/results.with_sst/'+model+'/'+period+'/H'+str(Hvalue)+'/'+huid+'/'+huid+'.'+model+'.'+period+'.event'+str(storm_count)+'.txt'
        filep = open(outfile, 'w')
    
        for t in np.arange(event_data.shape[0]):
            yy = int(event_data[t,0])
            mm = int(event_data[t,1])
            dd = int(event_data[t,2])
            hh = int(event_data[t,3])
            latp = event_data[t,4]
            lonp = event_data[t,5]
            height = event_data[t,6]
            [sstx, ssty] = latlon2xy(latp, lonp)
            if sstx<0:
                sstx = 0
            if sstx>259:
                sstx = 259
            if ssty<0:
                ssty = 0
            if ssty>459:
                ssty = 459
            sst_value = sst_data[int(sst_time_index[t,0]), sstx, ssty]
            if sst_value > 1000000:
                sst_value = -9999
            max_sst_value_hist = sst_max_hist_data[sstx, ssty]
            max_sst_value_future = sst_max_future_data[sstx, ssty]
            
            # way 1
            #if math.isnan(max_sst_value_hist):
            #    max_sst_value_hist = -9999
            #if math.isnan(max_sst_value_future):
            #    max_sst_value_future = -9999
            
            # way 2
            if max_sst_value_hist<100 or max_sst_value_hist>1000 or sst_max_hist_data.mask[sstx,ssty]==1:
                max_sst_value_hist = -9999.0
            if max_sst_value_future<100 or max_sst_value_future>1000 or sst_max_future_data.mask[sstx,ssty]==1:
                max_sst_value_future = -9999.0

            #print "%d  %d  %d  %d  %.5f  %.5f   %.2f  %.2f  %.2f  %.2f\n" % (yy, mm, dd, hh, latp, lonp, height, sst_value, max_sst_value_hist, max_sst_value_future)
            filep.writelines('%d  %d  %d  %d  %.5f  %.5f   %.2f  %.2f  %.2f  %.2f\n' % (yy, mm, dd, hh, latp, lonp, height, sst_value, max_sst_value_hist, max_sst_value_future))
            
        filep.close()
