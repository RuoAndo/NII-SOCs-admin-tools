import sys
import re
from numpy import *

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])

line = f.readline() 

ips = []
while line:
    tmp = line.split(",")
    if tmp[2] == "0":
        print "INWARD," + line.strip()
    if tmp[3] == "0":
        print "OUTWARD," + line.strip()
    else:
        print "TWO-WAY," + line.strip()


    line = f.readline() 

f.close()

