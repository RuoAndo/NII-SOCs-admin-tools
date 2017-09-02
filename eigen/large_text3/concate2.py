import sys
import re
from numpy import *
import linecache

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
counter = 1
while num < nCLUSTER:
  #print "CLUSTER" + str(num) + ":" + str(labels.count(str(num)))

  if labels.count(str(num)) > 0:
      target_line = linecache.getline(argvs[2], counter
      print str(labels.count(str(num))) + "," + target_line.strip()
      counter = counter + 1

  else:
      target_line = linecache.getline(argvs[3], num+1)
      tmp = target_line.split(",")
      print "0" + "," + str(tmp[1]) + "," + str(tmp[2]) + "," + str(tmp[3]) + "," + str(tmp[4]).strip()

  num = num + 1

f.close()

