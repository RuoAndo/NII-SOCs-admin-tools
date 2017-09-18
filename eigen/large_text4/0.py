import sys
import re
from numpy import *

CNO = 5

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])
line = f.readline() 
labels = []
counter = 0

while line:
    labels.append(line.strip())
    counter = counter + 1
    line = f.readline()

num = 0
while num < CNO:
    tmpstr = "CLUSTER" + str(num) + "," + str(labels.count(str(num))) 
    print tmpstr
    num = num + 1

f.close()

