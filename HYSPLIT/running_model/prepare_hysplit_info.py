#!/usr/bin/env python

import numpy as np
import netCDF4 as nc
import scipy.io as sio
import sys

def get_nc_data(infile, var):
    rootgroup = nc.Dataset(infile, 'r', format='NETCDF4')
    outdata = rootgroup.variables[var][:]
    rootgroup.close()
    return outdata

def get_matlab_data(infile, var):
    outdata = sio.loadmat(infile)[var]
    return outdata


def calc_basin_P1d_series(indata, huid):
    nt, nx, ny = indata.shape
    mask = np.zeros((nx, ny))
    for x in np.arange(nx):
        for y in np.arange(ny):
            if hu8_mask[x,y]==huid:
                mask[x,y]=1
    area_count = np.sum(np.sum(mask, axis=1))
    out_series = np.zeros((nt,1))
    for t in np.arange(nt):
        out_series[t] = np.sum(np.sum(indata[t,:,:]*mask, axis=1))
    outdata = out_series/area_count
    return mask,outdata

def P1d_to_P3d(indata):
    nt = indata.shape[0]
    outdata = indata[0:nt-2] + indata[1:nt-1] + indata[2:nt]
    return outdata


def pick_big_storms(indata, nevents):
    nt = indata.shape[0]
    # get independent storms (i.e. peaks of 3-day P)
    for t in np.arange(1,nt-1):
        if indata[t]<indata[t-1] or indata[t]<indata[t+1]:
            indata[t] = 0
    
    cdf_data = np.sort(indata, axis=None)
    threshold = cdf_data[nt-nevents-1]
    peak_date_index = np.zeros((nevents,1))
    peak_rainfall = np.zeros((nevents,1))
    count = 0
    for t in np.arange(1,nt-1):
        if indata[t]>threshold:
            peak_date_index[count] = t
            peak_rainfall[count] = indata[t]
            count = count + 1
    return peak_date_index, peak_rainfall


def determine_storm_center_info(indata, huid, date_index):
    nt, nx, ny = indata.shape
    mask = np.zeros((nx, ny))
    for x in np.arange(nx):
        for y in np.arange(ny):
            if hu8_mask[x,y]==huid:
                mask[x,y]=1
    basin_event_storm_data = np.zeros((3, nx, ny))
    for t in np.arange(3):
        basin_event_storm_data[t,:,:] = indata[int(date_index)+t,:,:]*mask
    (ind_t, ind_x, ind_y) = np.unravel_index(basin_event_storm_data.argmax(), basin_event_storm_data.shape)
    out_t = ind_t+int(date_index)
    out_lat = hu8_lat[ind_x]
    out_lon = hu8_lon[ind_y]
    return out_t, out_lat, out_lon


# parameters
model = sys.argv[1]  #'CMCC-CM'
period =  sys.argv[2]  #'hist'
nevents = int(sys.argv[3])  #100

#-----------------------------------------------------------------------------------------------
hu8file = '/raid2/xiaodong.chen/lulcc/ref_data/HU8_PNW_1_16.nc'
hu8_mask = get_nc_data(hu8file, 'Band1')
hu8_lat = get_nc_data(hu8file, 'lat')
hu8_lon = get_nc_data(hu8file, 'lon')

hu8listfile = '/raid2/xiaodong.chen/lulcc/ref_data/HU8_PNW_list.mat'
hu8_list = get_matlab_data(hu8listfile, 'HU8_PNW_list')

datefile = '/raid2/xiaodong.chen/lulcc/ref_data/year_month_day_'+period+'.mat'
year_list = get_matlab_data(datefile, 'year')
month_list = get_matlab_data(datefile, 'month')
day_list = get_matlab_data(datefile, 'day')

# load LOCA file, and remove the fillvalue.
locafile = '/raid/xiaodong.chen/lulcc/data/sim.proj/LOCA_cmip5_downscaled/latlon_by_model/use/loca.'+model+'.rcp85.'+period+'.nc'
loca_P = get_nc_data(locafile, 'pr')

# clean the mask issue, so now nodata grids will show 0.
locat, locax, locay = loca_P.shape
for x in np.arange(locax):
    for y in np.arange(locay):
        if loca_P.mask[0,x,y]==1:
            loca_P[0:locat,x,y] = np.zeros((locat))


for count in np.arange(220):
    outfile = '/raid/xiaodong.chen/lulcc/data/sim.proj/hysplit/input_info/top'+str(nevents)+'.in_time_order/'+model+'/'+period+'/'+str(hu8_list[count,0])+'.'+model+'.'+period+'.txt'
    filep = open(outfile, 'w')
    
    mask,P1day_series = calc_basin_P1d_series(loca_P, hu8_list[count,0])
    P3day_series = P1d_to_P3d(P1day_series)
    peak_storm_index, peak_rainfall = pick_big_storms(P3day_series,nevents)
    
    for nn in np.arange(nevents):
        center_tindex, center_lat, center_lon = determine_storm_center_info(loca_P, hu8_list[count,0], peak_storm_index[nn,0])
        center_year = year_list[center_tindex,0]
        center_month = month_list[center_tindex,0]
        center_day = day_list[center_tindex,0]
        filep.writelines('%d  %d  %d  %d  %.5f  %.5f  %.3f\n' % (center_tindex, center_year, center_month, center_day, center_lat, center_lon, peak_rainfall[nn,0]))
    filep.close()
