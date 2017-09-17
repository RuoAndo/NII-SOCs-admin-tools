import sys
import re
from numpy import *
import commands

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])
line = f.readline() 
n1 = []
while line:
    tmp = line.split(",")
    n1.append(tmp[1])
    line = f.readline()
f.close()

counter = 0
f = open(argvs[2])
line = f.readline() 
while line:
    tmp = line.split(",")
    if int(n1[counter]) == 0:
        argstr =  tmp[0] + " " + tmp[1] + " " + tmp[2].strip()
        check = commands.getoutput("./fill " + argstr + " 500000 6")
        print check
    else:
        print n1[counter].strip() + "," + line.strip()

    line = f.readline()
    counter = counter + 1
f.close()



    
