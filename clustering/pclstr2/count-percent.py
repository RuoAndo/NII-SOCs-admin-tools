import sys
import re
from numpy import *

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])
line = f.readline() 

counter = 0
sum = 0 
while line:
    tmp = line.split(",")
    sum = sum + int(tmp[1])
    counter = counter + 1
    line = f.readline()

f.close()
 
f = open(argvs[1])
line = f.readline() 

while line:
    tmp = line.split(",")
    #print tmp[1].strip()
    #print sum
    percent = float(tmp[1].replace("\n",""))/float(sum) 
    p2 = round(percent*100,5)
    print(line.strip() + ",(" + str(p2) + "%)")
    line = f.readline()

f.close()


