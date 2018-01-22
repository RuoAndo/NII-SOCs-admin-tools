import sys 
import os

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])
line = f.readline() 

while line:
    tmp = line.split(",") 
    #print tmp

    try:
        tmp2 = tmp[1].split(":")
        tmp3 = tmp2[0] + ":" + tmp2[1]
        tmp[1] = tmp3

    except:
        pass

    comstr = ""
    for x in tmp:
        comstr = comstr + x.rstrip() + "," 

    print comstr
    line = f.readline() 


f.close()
