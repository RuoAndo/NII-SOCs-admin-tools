import sys
import re

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])

line = f.readline() 

ipList = []
while line:
    tmp = line.split(",")

    ipList.append(tmp[1])
    ipList.append(tmp[2])

    line = f.readline() 

f.close()

ipList_uniq = list(set(ipList))

for i in ipList_uniq:
    print i
