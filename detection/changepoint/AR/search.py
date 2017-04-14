import sys 
import socket, struct
from binascii import hexlify
import numpy
import numpy as np

import datetime
from datetime import datetime as dt

argvs = sys.argv
 
f = open(argvs[1])

line = f.readline()

time_start = 0
time_end = 0

count = 0
while line:
    try:
        tmp = line.split(",")
        dt = datetime.datetime.strptime(tmp[1], '%Y-%m-%d %H:%M:%S.%f')
        dif = (dt-datetime.datetime(1970,1,1)).total_seconds()

        if count == 1:
            time_start = dif

    except:
        pass

    count = count + 1
    line = f.readline()

f.close()
    
time_end = dif

#print "start:" + str(time_start)
#print "end:" + str(time_end)

diff = time_end - time_start
#print diff

#start:1488283203.77
#end:1488890458.45
#607254.681

interval = int(diff) / 1000
#print interval

chpd = []

counter = 0
x = 0
while x < time_end:
   x = time_start + interval * counter
   chpd.append(int(x))
   counter = counter + 1

#print chpd

f = open(argvs[1])

line = f.readline()

time_start = 0
time_end = 0
count = 0

chpd2 = [0 for i in range(counter)]

while line:
    try:
        tmp = line.split(",")
        dt = datetime.datetime.strptime(tmp[1], '%Y-%m-%d %H:%M:%S.%f')
        dif = (dt-datetime.datetime(1970,1,1)).total_seconds()

        y = np.searchsorted(chpd, int(dif), side='right')

        chpd2[y] += 1
    
    except:
        pass

    line = f.readline()

f.close()

tmpstr = ""
for x in chpd2:
    tmpstr = tmpstr + "," + str(x)

print tmpstr 
