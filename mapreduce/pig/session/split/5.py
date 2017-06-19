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
clusterNo = argvs[2]

line = f.readline() 

labels = []

counter = 0

print "searching cluster: " + clusterNo
while line:
    tmp = line.split(",")

    if int(tmp[0]) == int(clusterNo):
        print clusterNo + ": " + str(counter)

    counter = counter + 1
    line = f.readline()

f.close()

