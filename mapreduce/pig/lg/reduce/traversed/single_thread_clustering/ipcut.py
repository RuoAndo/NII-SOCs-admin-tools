import sys
import re
from numpy import *

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])
line = f.readline() 

labels = []

counter = 0

ipList = []
while line:
    tmp = line.split(",")
    ipList.append(tmp[1])
    ipList.append(tmp[2])

    line = f.readline() 

ipList_uniq = list(set(ipList))

for i in ipList_uniq:
    print i

f.close()

