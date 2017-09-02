import sys
import re
from numpy import *
import math

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])
line = f.readline() 

plist = []

while line:
    tmp = line.split(",")
    plist.append(tmp[0])
    line = f.readline()

f.close()

f = open(argvs[2])
line = f.readline() 

nlist = []

while line:
    tmp = line.split(",")
    olist.append(tmp[0])
    line = f.readline()

f.close()

print olist
print nlist
