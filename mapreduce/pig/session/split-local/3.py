import sys
import re
from numpy import *
import numpy as np

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
        a[counter][0] =  int(tmp[0],10)
        a[counter][1] =  double(tmp[1])
        a[counter][2] =  double(tmp[2])

    counter = counter + 1
    
#print a
    
f.close()

#0,133.5.70.2,173.194.98.5,89,1
#0,130.87.34.2,192.43.172.30,669,1

f = open(argvs[2])

cluster_change_counter = 0

line = f.readline() 
while line:
    #print line.strip()

    
    tmp = re.split(r",", line)

    norms = []
    
    avg = np.c_[a[0][1], a[0][2]]
    ses = np.c_[double(tmp[3]),double(tmp[4])]
    distance = np.linalg.norm(avg-ses)
    #print "cluster 0" + ":" + str(avg) + ":" + str(ses) + ":" + str(distance)
    #print distance
    norms.append(distance)
    
    avg = np.c_[a[1][1], a[1][2]]
    ses = np.c_[double(tmp[3]),double(tmp[4])]
    distance = np.linalg.norm(avg-ses)
    #print "cluster 1" + ":" + str(avg) + ":" + str(ses) + ":" + str(distance)
    #print distance
    norms.append(distance)
    
    avg = np.c_[a[2][1], a[2][2]]
    ses = np.c_[double(tmp[3]),double(tmp[4])]
    distance = np.linalg.norm(avg-ses)
    #print "cluster 2" + ":" + str(avg) + ":" + str(ses) + ":" + str(distance)
    #print distance
    norms.append(distance)

    avg = np.c_[a[3][1], a[3][2]]
    ses = np.c_[double(tmp[3]),double(tmp[4])]
    distance = np.linalg.norm(avg-ses)
    #print "cluster 3" + ":" + str(avg) + ":" + str(ses) + ":" + str(distance)
    #print distance
    norms.append(distance)
    
    avg = np.c_[a[4][1], a[4][2]]
    ses = np.c_[double(tmp[3]),double(tmp[4])]
    distance = np.linalg.norm(avg-ses)
    #print "cluster 4" + ":" + str(avg) + ":" + str(ses) + ":" + str(distance)
    #print distance
    norms.append(distance)
    
    #print norms
    idx = np.argmin(norms)

    if(int(tmp[0]) != idx):
        #print "hit:" + tmp[0] + "->" + str(idx)
        print str(idx) + "," + tmp[1] + "," + tmp[2] + "," + tmp[3] + "," + tmp[4].strip()
        cluster_change_counter = cluster_change_counter + 1
        
    #print "---"
    line = f.readline()

print cluster_change_counter 
