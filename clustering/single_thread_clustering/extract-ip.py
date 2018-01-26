import sys
import re

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])

line = f.readline() 

ipList = []
while line:
    tmp = line.split(",")
    ipList.append(tmp[0])
    ipList.append(tmp[1])
    line = f.readline() 
f.close()

uniq = list(set(ipList))  # [2, 3, 4, 5]

for i in uniq:
    print i

