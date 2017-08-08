# python 1.py tools/libxl/libxl.c libxl 372

import sys 
import collections

import re
re_addr = re.compile("((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))")
re_num = re.compile("'[0-9]+'")
pattern = r"[a-xA-Z0-9_: ]+"

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

while line:
    tmp = line.split(",")

    try:
        #print tmp
        print tmp[7]
        print tmp[9]

    except:
        pass

    line = f.readline()


