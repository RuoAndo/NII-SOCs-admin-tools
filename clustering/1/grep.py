# python 1.py tools/libxl/libxl.c libxl 372

import sys 

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])
    
line = f.readline() 
    
while line:
    tmp = line.split(",")

    try:
        if int(tmp[0]) == int(argvs[2]):
            print line.strip()
    except:
        pass

    line = f.readline() 

