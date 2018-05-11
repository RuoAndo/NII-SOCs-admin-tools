import sys
import re

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])

line = f.readline() 

while line:
    tmp = line.split("\t")
    #print tmp[1]
    print tmp[0].strip()
    line = f.readline() 
f.close()
