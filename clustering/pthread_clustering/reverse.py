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

    if line.find("sip") > -1:
            tmp = line.split(":")
            #print tmp

            try:
                    tmp_int_1 = int2ip(int(float((tmp[9]))))
                    tmp_int_2 = int2ip(int(float((tmp[11]))))
           
                    ipList.append(tmp_int_1)
                    ipList.append(tmp_int_2)
 
                    #print str(tmp[1]) + ","  + str(tmp[3]) + ","  + str(tmp[5]) + ","  + str(tmp_int_1) + "," + str(tmp_int_2) + "," + str(tmp[13]) + ","  + str(tmp[15]) + ","  + str(tmp[17]);
    
            except:
                    pass
            
    
    line = f.readline()

print "######"
    
ipList_uniq = list(set(ipList)) 
for i in ipList_uniq:
        print i
