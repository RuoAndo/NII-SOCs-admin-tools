import sys
import re
import numpy as np
import math

def get_distance(x1, y1, x2, y2):
    d = math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)
    return d

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

print "CLUSTER0:" + str(labels.count("0"))
print "CLUSTER1:" + str(labels.count("1"))
print "CLUSTER2:" + str(labels.count("2"))
print "CLUSTER3:" + str(labels.count("3"))
print "CLUSTER4:" + str(labels.count("4"))

if (labels.count("2")==0):
    print "CLUSTER2:centroid"

    f3 = open(argvs[3])
    line3 = f3.readline()
    counter3 = 0
    while line3:

        if(counter3==2):
            tmp3 = line3.split(",")
            #print tmp3
            sidcountavg = float(tmp3[0])
            bytesavg = float(tmp3[1])
            
        counter3 = counter3 + 1
        line3 = f3.readline()

#############################
        
    f2 = open(argvs[2])
    line2 = f2.readline() 

    while line2:
        tmp2 = line2.split(",")
        #print tmp2
        sidcount = float(tmp2[4])
        byte = float(tmp2[3])
        
        a = np.array([sidcountavg, bytesavg])
        d = np.array([sidcount, byte])
        #print a
        #print d

        distance = get_distance(sidcount, byte, sidcountavg, bytesavg)
        print distance
        
        line2 = f2.readline()
        
f.close()

