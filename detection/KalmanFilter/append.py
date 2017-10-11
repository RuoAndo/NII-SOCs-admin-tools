# python 1.py tools/libxl/libxl.c libxl 372

import sys 

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])
line = f.readline() 
measure = []
while line:
    measure.append(line.strip())
    line = f.readline()

f = open(argvs[2])
line = f.readline() 
kf = []
while line:
    tmp = line.split(",")
    kf.append(tmp[0].strip())
    line = f.readline()


print kf
    
f = open('append', 'w') 

counter = 0
for i in measure:
    try:
        f.write(str(i) + "," + kf[counter] + "\n")
    except:
        pass
    counter = counter + 1
f.close() 

