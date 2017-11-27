import sys
import re
from numpy import *

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])

line = f.readline() 

counter = 0

ipList = []
while line:
    tmp = line.split(",")
    ipList.append(tmp[1])
    ipList.append(tmp[2])
    line = f.readline() 

#print ips

ips_uniq = list(set(ipList)) 

#print ips_uniq

for i in ips_uniq:
    print i

f.close()

