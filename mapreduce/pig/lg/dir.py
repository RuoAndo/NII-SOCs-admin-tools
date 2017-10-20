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
    if tmp[0] == argvs[2]:
        print "OUTWARD," + line.strip()
    if tmp[1] == argvs[2]:
        print "INWARD," + line.strip()

    line = f.readline() 

f.close()

