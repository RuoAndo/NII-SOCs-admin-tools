import sys
import re
from numpy import *

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

print "CLUSTER0," + str(labels.count("0")) 
print "CLUSTER1," + str(labels.count("1")) 
print "CLUSTER2," + str(labels.count("2")) 
print "CLUSTER3," + str(labels.count("3")) 
print "CLUSTER4," + str(labels.count("4")) 
print "CLUSTER5," + str(labels.count("5")) 
print "CLUSTER6," + str(labels.count("6")) 
print "CLUSTER7," + str(labels.count("7")) 
print "CLUSTER8," + str(labels.count("8")) 
print "CLUSTER9," + str(labels.count("9")) 

f.close()

