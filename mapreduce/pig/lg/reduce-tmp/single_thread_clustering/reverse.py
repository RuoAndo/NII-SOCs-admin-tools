# python 1.py tools/libxl/libxl.c libxl 372

import socket, struct
import sys 
from binascii import hexlify

def ip2int(addr):
        return struct.unpack("!I", socket.inet_aton(addr))[0]

def int2ip(addr):
        return socket.inet_ntoa(struct.pack("!I", addr))    

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

ipList = []

while line:
        tmp = line.split(",")
        
        tmp_int_1 = int2ip(int(float((tmp[1]))))
        tmp_int_2 = int2ip(int(float((tmp[2]))))
           
        print tmp[0] + "," + tmp_int_1 + "," + tmp_int_2 + "," + tmp[3] + "," + tmp[4] + "," + tmp[5].strip()
        
        line = f.readline()


