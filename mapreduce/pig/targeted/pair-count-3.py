# python 1.py tools/libxl/libxl.c libxl 372

import sys 
import collections

import re
re_str = re.compile("\([0-9]+\)")

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

alerts = []

while line:

    #print line
    # line2 = line.replace("{","").replace("}","")
    tmp = line.split(",")
        
    count_dict = collections.Counter(tmp)

    cdm = count_dict.most_common(10)
    #print cdm

    tmpstr = ""
    for j in cdm:
        tmpstr = tmpstr + str(j)
        # print tmpstr
    print tmpstr
        
        #m2 = re_str.search(str(j))
        #if m2 is not None:
        #    alerts.append(str(j).replace("(","").replace(")","").replace("\"",""))

    line = f.readline() 

#print alerts

#alerts2 = str(alerts).replace("\"","").replace("'","").replace("[","").replace("]","")
#print alerts2

#b= alerts2.split(",")
#print b

#di2 = dict(zip(b[0::2], b[1::2]))
#print di2
#print di2[" HTTP SQL Injection Attempt35823"]

#di1 = dict(b)
#print di1

#di2 = dict(zip(alerts[0::2], alerts[1::2]))
#print di2
