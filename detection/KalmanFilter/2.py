# python 1.py tools/libxl/libxl.c libxl 372

import sys 

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

kflist = []
while line:
    tmp = line.split(",")
    #print(tmp[1].strip())
    kflist.append(tmp[1].strip())
    
    line = f.readline()

sum = 0
counter = 0
for i in kflist:
    sum = sum + float(i)
    if counter == 12:
        print(sum)
        sum = 0
        counter = 0
    counter = counter + 1

