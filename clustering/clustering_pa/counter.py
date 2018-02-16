import sys
import re
from numpy import *

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])
line = f.readline() 

counter = 0

while line:
    tmp = line.split(",")
    line = f.readline() 
    counter = counter + 1

print len(tmp)
print counter

f.close()

