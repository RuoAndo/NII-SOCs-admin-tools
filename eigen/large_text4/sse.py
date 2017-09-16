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

f = open(argvs[2])
line = f.readline() 
n2 = []
while line:
    tmp = line.split(",")
    n2.append(tmp[1])
    line = f.readline()
f.close()

counter = 0
for i in n1:
    print abs(int(i)-int(n2[counter]))
    counter = counter + 1
    
