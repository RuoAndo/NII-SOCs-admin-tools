# python 1.py tools/libxl/libxl.c libxl 372

import sys 
import socket, struct
from binascii import hexlify

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

while line:
    tmp = line.split("\t")
    #print tmp

    dst = struct.unpack('I', socket.inet_aton(tmp[7]))[0]
    #print dst

    src = struct.unpack('I', socket.inet_aton(tmp[7]))[0]
    #print src

    print str(dst) + "," + str(src) + "," + str(tmp[26])
    
    line = f.readline() 
