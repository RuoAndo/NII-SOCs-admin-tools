import sys
import re
from numpy import *

#['1', '1.107591480065538', '706.4975423265975\n']
#['2', '1.0778210116731517', '1846.2707059477486\n']
#['3', '1.0812533191715348', '5335.106744556559\n']
#['4', '1.1299060254284135', '1336.4262023217248\n']

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

print "CLUTER0:" + str(labels.count("0"))
print "CLUTER1:" + str(labels.count("1"))
print "CLUTER2:" + str(labels.count("2"))
print "CLUTER3:" + str(labels.count("3"))
print "CLUTER4:" + str(labels.count("4"))

f.close()

