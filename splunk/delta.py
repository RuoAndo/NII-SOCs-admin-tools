# python 1.py tools/libxl/libxl.c libxl 372

import sys 
import re

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

while line:

    tmp = line.split(",")

    try:
        #print tmp[2]
        print str(abs(float(tmp[2].replace("\"","")))).strip()

    except:
        pass
        
    line = f.readline()


