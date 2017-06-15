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

a = zeros((5, 3))

line = f.readline() 
tmp = re.split(r",", line)
#print tmp[0]
a[0][0] =  int(tmp[0],10)
a[0][1] =  double(tmp[1])
a[0][2] =  double(tmp[2])

counter = 1
while line:
    line = f.readline()

    if counter < 5:
        tmp = re.split(r",", line)
        #print tmp[0]
        #print tmp[0].isdigit()
        a[counter][0] =  int(tmp[0],10)
        a[counter][1] =  double(tmp[1])
        a[counter][2] =  double(tmp[2])
        #a[0][counter] =  1

    counter = counter + 1
    
#print a
    
f.close()

#['1', '1.107591480065538', '706.4975423265975\n']
#['2', '1.0778210116731517', '1846.2707059477486\n']
#['3', '1.0812533191715348', '5335.106744556559\n']
#['4', '1.1299060254284135', '1336.4262023217248\n']

f = open(argvs[2])

line = f.readline() 
while line:
    line = f.readline()
    try:
        tmp = re.split(r",", line)

        #print a
        #print str(tmp[3]) + ":" + str(a[0][1])
        i3 = double(tmp[3]) - a[0][1]
        #print str(tmp[4]).rstrip() + ":" + str(a[0][2])
        i4 = double(tmp[4]) - a[0][2]

        print str(tmp[0]) + ":" + str(tmp[1]) + ":" + str(tmp[2]) + ":" + str(i3) + ":" + str(i4)
        
    except:
        pass
