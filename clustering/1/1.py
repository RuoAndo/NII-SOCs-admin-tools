# python 1.py tools/libxl/libxl.c libxl 372

import sys 


argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])
    
line = f.readline() 
    
while line:
    tmp = line.split(",")
    print str(tmp[-3]).replace("\"","") + "," + str(tmp[-2]) + "," + str(tmp[-1]).strip()
    line = f.readline() 

