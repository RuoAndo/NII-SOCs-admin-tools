# python 1.py tools/libxl/libxl.c libxl 372

import sys 
import collections
argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])
line = f.readline() 

tpl = []

while line:
    tmp = line.split(",")
    
    try:
        #print tmp[3].strip()
        
        #if int(float(tmp[2])) > 60:
            #print tmp
        #    tpl.append(tmp)
        if int(float(tmp[3].strip())) > 0:
            #print tmp
            tpl.append(tmp)

    except:
        pass

    line = f.readline() 

fl = list(sorted(tpl, key=lambda tpl: int(tpl[3]), reverse=True))

for i in fl:
    comstr = ""
    for j in list(i):
        comstr = comstr + j.rstrip() + ","
    
    print comstr.rstrip()
