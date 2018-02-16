import sys
import re
from numpy import *
import commands

argvs = sys.argv
argc = len(argvs)

prev = []

f = open(argvs[1])
line = f.readline() 
while line:
    prev.append(line.strip())
    line = f.readline()
f.close()

now = []

f = open(argvs[2])
line = f.readline() 
while line:
    now.append(line.strip())
    line = f.readline()
f.close()

counter = 0
counter2 = 0
for x in now:
    if x != prev[counter]:
        counter2 = counter2 + 1
    counter = counter + 1
    
print counter2
    
