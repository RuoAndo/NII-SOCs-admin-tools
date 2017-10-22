import sys 
import numpy as np

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline()

sessionseries = []
flag = np.array([])

counter = 0
while line:
    tmp = line.split(",")

    if len(tmp[2]) > 0 and int(tmp[2]) == int(argvs[2]):
        sessionseries.append(tmp[3].strip())
        flag = np.append(flag,1)

    else:
        flag[counter:counter]=0
        
    counter = counter + 1
    line = f.readline()

f.close()

counter = 0
for i in flag:
    if int(i) == 1:
        print str(counter) + "," + str(sessionseries[counter])
    else:
        print str(counter) + "," + "0"
    counter = counter + 1

#for i in sessionseries:
#    print i
