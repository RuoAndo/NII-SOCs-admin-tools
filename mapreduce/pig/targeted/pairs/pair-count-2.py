# python 1.py tools/libxl/libxl.c libxl 372

import sys 
import collections

import re
re_addr = re.compile("((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))")
re_num = re.compile("[a-z][A-Z]*")
re_num2 = re.compile("\'[0-9]\'")

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

while line:
    tmp = line.split(",")

    tmpstr = ""
    
    for i in tmp:
         m = re_addr.search(i)
         if m is not None:
             tmpstr = tmpstr + i.rstrip().strip(")") + ","

    #print tmpstr
    
    count_dict = collections.Counter(tmp)
    #print count_dict
    cdm = count_dict.most_common(5)
    #print cdm

    tmpstr2 = ""
    for j in cdm:
        #print j
        m2 = re_addr.search(str(j))
        if m2 is None:

            m3 = re_num.search(str(j))
            if m3 is not None:            
                tmpstr2 = tmpstr2 + "," + str(j)

    tmpcon = tmpstr.rstrip() + tmpstr2.rstrip()
            
    m4 = re_num2.search(tmpcon)
    if m4 is None:            
        print tmpcon.replace(",,",",")
                

                
    line = f.readline() 
