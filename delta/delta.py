# python 1.py tools/libxl/libxl.c libxl 372

import sys
import time
import datetime
from datetime import datetime

def datetime_to_epoch(d):
    return int(time.mktime(d.timetuple()))


def epoch_to_datetime(epoch):
    return datetime(*time.localtime(epoch)[:6])
        
argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])
line = f.readline() 

while line:
    tmp = line.split(",")
    tmp2 = tmp[1].split(" ")
    
    if len(tmp2) > 1:
        strt = tmp2[0].replace("\"","") + " " + tmp2[1].replace("\"","")
        tmp3 = strt.split(".")
        
        new_date = datetime.strptime(tmp3[0], '%Y-%m-%d %H:%M:%S')
        epoch = datetime_to_epoch(new_date)
        print str(epoch) + "," + tmp[8]
        
    line = f.readline()


