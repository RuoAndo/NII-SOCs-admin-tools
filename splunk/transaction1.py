# python 1.py tools/libxl/libxl.c libxl 372

import sys 
import re

argvs = sys.argv  
argc = len(argvs) 

pattern=r'([+-]?[0-9]+\.?[0-9]*)'

f = open(argvs[1])

line = f.readline() 

while line:
    tmp = line.split(",")
    
    tmp2 = re.split(r'\([+-]?[0-9]+\.?[0-9]*\)', tmp[1]) 

    lw = len(tmp2)-1
    print tmp[0] + "," + str(lw) + "," + tmp[2] + "," + tmp[3].strip()
    
    #constr = ""
    for x in tmp2:
        print x.replace("\"","").replace(" ","").strip()
                
    #print constr.strip("\"") 
        
    line = f.readline()


