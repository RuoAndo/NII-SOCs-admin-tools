import sys
import re
from numpy import *
import linecache

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])
line = f.readline() 

nlist = []

while line:
    tmp = line.split(",")

    nlist.append(int(tmp[1]))

    line = f.readline()

#print nlist
f.close()

f2 = open(argvs[2])
line2 = f2.readline() 

flag = 0
while line2:
    tmp2 = line2.split(",")

    for i in nlist:
        if int(i) == int(tmp2[0]):
            target_line = linecache.getline(argvs[1], i)
            flag = 1
        else:
            flag = 0

    if flag == 1:
        print target_line.strip()
    else:
        print line2.strip()

    line2 = f2.readline()

f2.close()
