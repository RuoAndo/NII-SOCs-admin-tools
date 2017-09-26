import sys
import re
from numpy import *

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
    print n1[counter] + "," + line.strip()
    line = f.readline()
    counter = counter + 1
f.close()



    
