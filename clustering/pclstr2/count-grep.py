import sys
import re
from numpy import *

import socket, struct
import sys 
from binascii import hexlify

re_addr = re.compile("((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))")

def ip2int(addr):
        return struct.unpack("!I", socket.inet_aton(addr))[0]

def int2ip(addr):
        return socket.inet_ntoa(struct.pack("!I", addr))    

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])
line = f.readline() 

number = {}
counter = 0

while line:
    tmp = line.split(",")
    number[counter] = tmp[1].strip()
    
    counter = counter + 1
    line = f.readline()
f.close()
 
#print number

#sorted = sorted(number.values())
s =  sorted(number.items(), key=lambda x: int(x[1]))
#print s

#for x in s:
#    print x[0]

counter = 0

ipList = []

for x in s:
    if counter < 16:

        #print x
        #print argvs[2]
        f = open(argvs[2])
        line = f.readline() 
        while line:
            tmp = line.split(",")
            #print tmp

            try:
                if int(tmp[0]) == int(x[0]):
                    #print line.strip()
                    #print str(tmp[0]) + "," + str(int2ip(int(tmp[1]))) + "," + str(int2ip(int(tmp[2]))) + "," + str(tmp[3]) + "," + str(tmp[4]) + "," + str(tmp[5])
                    ipList.append(int2ip(int(tmp[1])))
                    ipList.append(int2ip(int(tmp[2])))

            except:
                pass

            line = f.readline() 

        f.close()

    counter = counter + 1

ipList_uniq = list(set(ipList)) 

for x in ipList_uniq:
        print(x)
