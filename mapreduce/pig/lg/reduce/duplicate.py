import sys
import re
from numpy import *

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])

line = f.readline() 

ipList1 = []

while line:
    #tmp = line.split(",")
    #print tmp[2]
    ipList1.append(line.strip())
    line = f.readline() 

f = open(argvs[2])

line = f.readline() 

ipList2 = []

while line:
    #tmp = line.split(",")
    #print tmp[2]
    ipList2.append(line.strip())
    line = f.readline() 

andList = list( set(ipList2) & set(ipList1) )

counter = 0

#for i in andList:
#    counter = counter + 1

#print "### AND(ALREADY SEEN):"+ str(counter) + "###"

#for i in andList:
#    print i

#print "####"
#print "####"
#print "####"

diffList = list( set(ipList2) - set(ipList1) )

counter = 0

for i in diffList:
    counter = counter + 1

print "### DIFF(NEWLY OBSERVED):" + str(counter) + "###"
for i in diffList:
    print i


