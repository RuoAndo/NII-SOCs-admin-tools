# python 1.py tools/libxl/libxl.c libxl 372

import sys 
import collections

import re
re_addr = re.compile("((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))")
re_num = re.compile("'[0-9]+'")

#pattern = r"[a-xA-Z0-9_:.() ]+"
pattern = r"[a-zA-Z0-9]+"

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

anames = []

while line:
    tmp = line.split(",")
    #print tmp
    anames.append(tmp[25])
    line = f.readline()

count_dict = collections.Counter(anames)
#print count_dict
count_dict_list = count_dict.items()

f.close()

##################

f = open(argvs[2])

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
            
    count_dict2 = collections.Counter(tmp)
    #print count_dict2

    #for j in count_dict2:
    #    print j
    
    for k, v in count_dict2.items():
        searchstr = k.replace("{","").replace("}","").lstrip("(")[:-1] 
        searchcnt = v
        allcnt = count_dict[searchstr]

        m = re_addr.search(searchstr)
        if m is None and len(searchstr) > 20:
            #print str(searchstr) + "," + str(searchcnt) + "," + str(allcnt)
            tmpstr = tmpstr + str(searchstr) + "," + str(searchcnt) + "," + str(allcnt) + ","

    print tmpstr

    line = f.readline() 

