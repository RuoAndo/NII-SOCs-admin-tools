# python 1.py tools/libxl/libxl.c libxl 372

import sys 

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

sum = 0
while line:
    tmp = line.split(",")
    sum = sum + int(tmp[2])
    line = f.readline()

print sum




