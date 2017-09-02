import sys
import re
from numpy import *

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])
line = f.readline() 

labels = []
counter = 0
nCLUSTER = 10

while line:
    tmp = line.split(",")
    labels.append(tmp[0])
    counter = counter + 1
    line = f.readline()

num = 0
while num < nCLUSTER:
  #print "CLUSTER" + str(num) + ":" + str(labels.count(str(num)))
  num = num + 1

f.close()

f2 = open(argvs[2])
line2 = f2.readline() 

num = 0
while line2:
    print str(labels.count(str(num))) + "," + line2.replace("\n","")
    num = num + 1
    line2 = f2.readline()
