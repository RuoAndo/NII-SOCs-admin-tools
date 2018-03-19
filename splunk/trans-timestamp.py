# python 1.py tools/libxl/libxl.c libxl 372

import sys 
import time
from datetime import datetime


#import time
#from datetime import datetime

def datetime_to_epoch(d):
        return int(time.mktime(d.timetuple()))

def epoch_to_datetime(epoch):
    return datetime(*time.localtime(epoch)[:6])

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])
line = f.readline() 

counter = 0
while line:
    tmp = line.split(",")
    #print tmp

    if counter == 0:
            print line.strip()
    
    if counter > 0:
            #tmp2 = str(epoch_to_datetime(int(tmp[0])))
            tmp2 = datetime.fromtimestamp(int(tmp[0]))
            print str(tmp2) + str(tmp[1:-1])
            #tmp3 = tmp2.split(" ")
            #print tmp3[0] + "," + tmp[1] + "," + tmp[2].strip()
                    
    counter = counter + 1
    line = f.readline()


