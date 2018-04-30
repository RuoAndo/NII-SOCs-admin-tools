import sys
import re
from numpy import *

import socket, struct
import sys 
from binascii import hexlify

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])
line = f.readline() 

number = {}
#print number
counter = 0

while line:
    tmp = line.split(",")
    #print tmp

    number[int(tmp[0])] = 0
        
    counter = counter + 1
    line = f.readline()
f.close()

#print number

f = open(argvs[1])
line = f.readline() 

counter = []

sum = 0
while line:
    tmp = line.split(",")
    #print tmp

    number[int(tmp[0])] = number[int(tmp[0])] + 1
        
    counter.append(int(tmp[0]))
    line = f.readline()
    sum = sum + 1
f.close()

print number
counter_uniq = list(set(counter))

for x in counter_uniq:
    print str(x) + ":" + str((float(number[x]) / float(sum)) * 100)
    #print str(counter) + ":" + str(float(x)) + str(x) + ":" + str((float(number[x]) / float(counter))* 100 )
    
    
