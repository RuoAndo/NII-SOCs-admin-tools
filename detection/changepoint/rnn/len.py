# python 1.py tools/libxl/libxl.c libxl 372

import sys 

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

srcip = []
while line:
    tmp = line.split(" ")
    print tmp
    print len(tmp)
    line = f.readline() 

