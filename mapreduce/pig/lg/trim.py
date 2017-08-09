# python 1.py tools/libxl/libxl.c libxl 372

import sys 

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

while line:
    tmp = line.replace("(","").replace(")","")
    print tmp.strip()
    line = f.readline()


