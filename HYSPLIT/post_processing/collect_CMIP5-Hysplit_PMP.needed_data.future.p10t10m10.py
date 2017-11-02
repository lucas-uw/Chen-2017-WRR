#!/usr/bin/env python

import numpy as np
import scipy.io as sio
import sys

def sst2pw(sstdata):
    # data taken from WMO1986, Annx 1
    # input sst is in C (so K-273.15)
    sstarray = np.arange(31)
    prwarray = np.array([8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 15.0, 16.0, 18.0, 19.0, 21.0, 23.0, 25.0, 28.0, 30.0, 33.0,
                         36.0, 40.0, 44.0, 48.0, 52.0, 57.0, 62.0, 68.0, 74.0, 81.0, 88.0, 96.0, 105.0, 114.0, 123.0])
        
    return np.interp(sstdata, sstarray, prwarray)


def collect_storm_rep_sst1(huidstr, ne):
    hysplitfile = resultdir + '/'+model+'/'+period+'/H'+Hvalue+'/'+huidstr+'/'+huidstr+'.'+model+'.'+period+'.event'+str(ne)+'.txt'
    #print hysplitfile
    hysplit_results = np.genfromtxt(hysplitfile)
    nt = hysplit_results.shape[0]
    ratio = 1.0
    #for i in np.arange(np.minimum(132, hysplit_results.shape[0])):   # 5day data
    for i in np.arange(hysplit_results.shape[0]):
        if hysplit_results[i,6]<200 and hysplit_results[i,7]>0:
            ratio_tmp = sst2pw(hysplit_results[i,9]-273.12)/sst2pw(hysplit_results[i,7]-273.12) 
            if ratio_tmp>ratio:
                ratio = ratio_tmp
                year = hysplit_results[i,0]
                month = hysplit_results[i,1]
                day = hysplit_results[i,2]
                lat = hysplit_results[i,4]
                lon = hysplit_results[i,5]
                sst_rep = hysplit_results[i,7]-273.12
                sst_max1 = hysplit_results[i,8]-273.12
                sst_max2 = hysplit_results[i,9]-273.12
    if ratio==1.0:
        year = -9999
        month = -9999
        day = -9999
        lat = -9999
        lon = -9999
        sst_rep = -9999
        sst_max1 = -9999
        sst_max2 = -9999
    
    return year, month, day, lat, lon, sst_rep, sst_max1, sst_max2

inputdir = '/raid/xiaodong.chen/lulcc/data/sim.proj/hysplit/input_info'
resultdir = '/raid/xiaodong.chen/lulcc/data/sim.proj/hysplit/results.with_sst'
outputdir = '/raid/xiaodong.chen/lulcc/data/sim.proj/hysplit/pmp_results'

model = sys.argv[1]
Hvalue = str(sys.argv[2])
period = 'future'

hu8file = '/raid2/xiaodong.chen/lulcc/ref_data/HU8_PNW_list.mat'
hu8_list = sio.loadmat(hu8file)['HU8_PNW_list']

for n in np.arange(220):
    huidstr = str(hu8_list[n,0])
    infile = inputdir + '/top200/'+model+'/'+'future.p10t10m10'+'/'+huidstr+'.'+model+'.'+'future.p10t10m10'+'.txt'
    outfile = outputdir + '/results_for_RT_experiments/10day_results/'+model+'/'+'future.p10t10m10'+'/H'+Hvalue+'/'+huidstr+'.'+model+'.H'+Hvalue+'.'+'future.p10t10m10'
    #print infile
    #print outfile
    #exit()
    filep = open(outfile, 'w')
    storm_data_full = np.genfromtxt(infile)

    for e in np.arange(100):
        ne = e + 1
        p3d = float(storm_data_full[e,6])
        year, month, day, lat, lon, sst_value, sst_max_hist, sst_max_future = collect_storm_rep_sst1(huidstr, ne)
        filep.writelines('%.3f  %d  %d  %d  %.3f  %.3f  %.2f  %.2f  %.2f\n' % (p3d, year, month, day, lat, lon, sst_value, sst_max_hist, sst_max_future))

    filep.close()
