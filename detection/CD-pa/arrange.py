import sys 
import os

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])
line = f.readline() 

while line:
    if len(line) == 58:
        print line.strip()

    #print str(len(line)) + line
    line = f.readline() 

f.close()
