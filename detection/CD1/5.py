# python 1.py tools/libxl/libxl.c libxl 372

import sys 

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

l = []
while line:
    tmp = line.split(",")
    l.append(float(tmp[1]))
    #print(tmp[1].strip())

    line = f.readline()

counter = 0
for i in l:
    print(str(counter) + "," + str(i))
    counter = counter + 1
    

