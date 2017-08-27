import sys
import re
import random
#from numpy import *
import numpy as np

#['4', '1.1299060254284135', '1336.4262023217248\n']

argvs = sys.argv
argc = len(argvs)

f2 = open(argvs[2])
line2 = f2.readline() 

counter = 0

avg_c0 = []
avg_c1 = []
avg_c2 = []
avg_c3 = []
avg_c4 = []

while line2:
    tmp2 = line2.split(",")
    
    if counter == 0:
        for i in tmp2:
            avg_c0.append(i)

    if counter == 1:
        for i in tmp2:
            avg_c1.append(i)

    if counter == 2:
        for i in tmp2:
            avg_c2.append(i)

    if counter == 3:
        for i in tmp2:
            avg_c3.append(i)

    if counter == 4:
        for i in tmp2:
            avg_c4.append(i)

    counter = counter + 1
    line2 = f2.readline() 

print avg_c0
print avg_c1
print avg_c2
print avg_c3
print avg_c4

f = open(argvs[1])
line = f.readline() 

labels = []
counter = 0

while line:
    tmp = line.split(",")
    labels.append(tmp[0])
    counter = counter + 1
    line = f.readline()

if labels.count("0") == 0:
    print "HIT"

    f3=open(argvs[1])
    line3=f3.readline()

    while line3:
        tmp = line.split(",")

        counter = counter + 1
        line = f.readline()

    s=random.choice(lines)
    print "".join(s)    

print "CLUTER0:" + str(labels.count("0"))
print "CLUTER1:" + str(labels.count("1"))
print "CLUTER2:" + str(labels.count("2"))
print "CLUTER3:" + str(labels.count("3"))
print "CLUTER4:" + str(labels.count("4"))

f.close()

