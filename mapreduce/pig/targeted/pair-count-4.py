# python 1.py tools/libxl/libxl.c libxl 372

import sys 
import collections

import re
re_addr = re.compile("((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))")

pattern = r"[a-xA-Z0-9_: ]+"

argvs = sys.argv  
argc = len(argvs) 




f = open(argvs[1])

line = f.readline() 

alerts = []

while line:

    tmp = line.split(",")

    tmpstr = ""
    for i in tmp:
        m = re_addr.search(str(i))
        if m is not None:
            tmpstr = tmpstr + str(i).replace(")","").strip() + ","

    #print tmpstr        
            
    count_dict = collections.Counter(tmp)

    cdm = count_dict.most_common(5)

    for j in cdm:
        m2 = re_addr.search(str(j))
        if m2 is None:
            matchedList = re.findall(pattern,str(j))

            if(len(matchedList)>2):
                print matchedList[0]  
            #tmpstr = tmpstr + str(j).replace("'(","").lstrip() + ","

    print tmpstr
        
    line = f.readline() 

