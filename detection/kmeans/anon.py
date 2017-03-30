import sys 
import socket, struct
from binascii import hexlify
from prettyprint import pp

argvs = sys.argv
 
f = open(argvs[1])
line = f.readline() 

dstIPs = []

while line:
    tmp = line.split(",")        
    dstIPs.append(tmp[2])
    line = f.readline() 
    
f.close()
    
dstIP_uniq = list(set(dstIPs))

counter = 0
dict = {}
for x in dstIP_uniq:
    dict.update({counter: x})
    #print dict
    counter = counter + 1

#print dict

f2 = open(argvs[1])
line2 = f2.readline() 

while line2:
    tmp = line2.split(",")        

    for x,y in dict.items():
        if y == tmp[2]:
            print tmp[0] + "," + tmp[1] + "," + str(x) + "," + tmp[3] + "," + tmp[4].strip()
    
    #tmpstr = ",".join(v for k, v in dict.items())
    
    line2 = f2.readline()
        

