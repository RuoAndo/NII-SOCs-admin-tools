# python 1.py tools/libxl/libxl.c libxl 372

import sys 
import re

import socket, struct
from binascii import hexlify

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 
    
while line:
        line = line.replace("[","").replace("]","")
        #print line
        tmp = re.split('\s+',line)
        print tmp[1] + "," + tmp[2]

        line = f.readline() 
    

