# python 1.py tools/libxl/libxl.c libxl 372

import sys 

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

while line:
    
    tmp = line.split("\t")
    print tmp[0]

    line = f.readline()


