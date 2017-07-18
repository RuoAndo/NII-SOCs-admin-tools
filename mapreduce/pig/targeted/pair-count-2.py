# python 1.py tools/libxl/libxl.c libxl 372

import sys 
import collections

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

while line:
    tmp = line.split(",")
    #print tmp
    count_dict = collections.Counter(tmp)
    print count_dict
    
    line = f.readline() 
