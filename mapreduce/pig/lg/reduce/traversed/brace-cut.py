import sys
import re

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])

line = f.readline() 

while line:
    tmpstr = line.replace("(","").replace(")","").strip()
    tmp = tmpstr.split(",")
    
    if tmp[2] > 0 and tmp[3] > 0:
        print "TWO-WAY," + tmpstr

    if tmp[2] > 0:
        print "INWARD," + tmpstr

    if tmp[3] > 0:
        print "OUTWARD," + tmpstr 

    line = f.readline() 
f.close()
