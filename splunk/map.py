# python 1.py tools/libxl/libxl.c libxl 372

import sys 
import time
from datetime import datetime

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])
line = f.readline() 

attack = {}

while line:
    tmp = line.split(",")
    attack[tmp[0]] = tmp[1].strip()
    line = f.readline()

#print attack

f.close()

#####

f = open(argvs[2])
line = f.readline() 

target = {}

while line:
    tmp = line.split(",")
    target[tmp[0]] = tmp[1].strip()
    line = f.readline()

#print attack

f.close()

for x in attack:
    for y in target:
        if x == y:
            #print "HIT"
            tmp = int(attack[x]) + int(target[y])
            print x + "," + attack[x] + "," + target[y] + "," + str(tmp)

