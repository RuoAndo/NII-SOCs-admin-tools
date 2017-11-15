import sys
import re
from numpy import *

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])

line = f.readline() 

counter = 0

ips = []
while line:
    tmp = line.split(",")
    ips.append(tmp[0])
    ips.append(tmp[1])
    line = f.readline() 

#print ips

ips_uniq = list(set(ips)) 
ips_uniq.remove(str(argvs[2]))

#print ips_uniq

for i in ips_uniq:
    print i

f.close()

