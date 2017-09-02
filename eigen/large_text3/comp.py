import sys
import re
from numpy import *
import math

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])
line = f.readline() 

plist = []

while line:
    tmp = line.split(",")
    plist.append(tmp[0])
    line = f.readline()

f.close()

f = open(argvs[2])
line = f.readline() 

olist = []

while line:
    tmp = line.split(",")
    olist.append(tmp[0])
    line = f.readline()

f.close()

plistsum = 0
for i in plist:
    plistsum = plistsum + double(i)

comstr = ""
for i in plist:
    comstr = comstr + str(i) + "(" + str(round((double(i)/plistsum)*100,1)) + "%),"

print "previous:" + comstr

comstr = ""
for i in olist:
    comstr = comstr + str(i) + "(" + str(round((double(i)/plistsum)*100,1)) + "%),"

print "current:" + comstr

counter = 0
dlist = []
SSE = 0
for i in plist:
    diff = float(olist[counter]) - float(plist[counter])
    #print abs(diff)
    SSE = SSE + abs(diff)
    dlist.append(abs(diff))
    counter = counter + 1

print dlist
print SSE

f2 = open('SSE', 'a')
f2.write(str(SSE)+"\n")
f2.close()


