import sys
import re
from numpy import *
import math

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])
line = f.readline() 
labels = []
counter = 0

while line:
    tmp = line.split(",")
    labels.append(tmp[0])
    counter = counter + 1
    line = f.readline()

f2 = open(argvs[2])
line2 = f2.readline() 
labels2 = []

while line2:
    try:
        tmp2 = line2.split(",")
        labels2.append(tmp2[1])
    except:
        pass

    line2 = f2.readline()

print labels2

print "CLUSTER0," + str(labels.count("0")) + "<" + labels2[0].strip()
print "CLUSTER1," + str(labels.count("1")) + "<" + labels2[1].strip()
print "CLUSTER2," + str(labels.count("2")) + "<" + labels2[2].strip()
print "CLUSTER3," + str(labels.count("3")) + "<" + labels2[3].strip()
print "CLUSTER4," + str(labels.count("4")) + "<" + labels2[4].strip()
print "CLUSTER5," + str(labels.count("5")) + "<" + labels2[5].strip()
print "CLUSTER6," + str(labels.count("6")) + "<" + labels2[6].strip()
print "CLUSTER7," + str(labels.count("7")) + "<" + labels2[7].strip()
print "CLUSTER8," + str(labels.count("8")) + "<" + labels2[8].strip()
print "CLUSTER9," + str(labels.count("9")) + "<" + labels2[9].strip()

SSE = pow((int(labels.count("0")) - int(labels2[0].strip())),2) + pow((int(labels.count("1")) - int(labels2[1].strip())),2) + pow((int(labels.count("2")) - int(labels2[2].strip())),2) + pow((int(labels.count("3")) - int(labels2[3].strip())),2) + pow((int(labels.count("4")) - int(labels2[5].strip())),2) + pow((int(labels.count("6")) - int(labels2[6].strip())),2) + pow((int(labels.count("7")) - int(labels2[7].strip())),2) + pow((int(labels.count("8")) - int(labels2[8].strip())),2) + pow((int(labels.count("9")) - int(labels2[9].strip())),2) 
print math.sqrt(SSE)

f.close()

f2 = open('SSE', 'a')
f2.write(math.sqrt(SSE))
f2.close()
