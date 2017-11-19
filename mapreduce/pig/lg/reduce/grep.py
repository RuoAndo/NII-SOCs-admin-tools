import sys
import re

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])
line = f.readline() 

labels = []
counter = 0

while line:
    tmp = line.split(",")
    #print tmp[1].strip()

    f2 = open(argvs[2])
    line2 = f2.readline() 
    while line2:
        if line2.find(tmp[1].strip()) > -1:
            print "[" + tmp[1].strip() + "]" + "[" + tmp[0] + "]" + ":" + line2.strip()
        line2 = f2.readline() 

    line = f.readline()
f.close()
