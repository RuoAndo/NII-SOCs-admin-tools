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

print dict

        

