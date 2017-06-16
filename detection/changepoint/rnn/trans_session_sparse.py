# python 1.py tools/libxl/libxl.c libxl 372

import sys 

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

srcip = []
while line:
    tmp = line.split(",")
    srcip.append(tmp[9])
    line = f.readline() 

srcip_uniq = list(set(srcip)) 
    
#print len(srcip_uniq)
    
f.close()

f2 = open(argvs[1])
line2 = f2.readline() 

while line2:
    tmp = line2.split(",")

    counter = 0

    comstr = ""
    for x in srcip_uniq:

        if tmp[9] == x:
            comstr = comstr + "1 "
        else:
            comstr = comstr + "0 "

        counter = counter + 1

    #print str(counter) + ":"
    print comstr
        
    line2 = f2.readline()
    
