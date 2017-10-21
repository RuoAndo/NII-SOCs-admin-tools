import sys 
import os
import commands

argvs = sys.argv  
argc = len(argvs) 


f = open(argvs[1])
line = f.readline() 

while line:
    tmp = line.split(",")
    #print(tmp[1])
    
    comstr = "grep -n " + "\"" + tmp[1] + "\"" + " " + argvs[2]
    #print(comstr)
    check = commands.getoutput(comstr)    
    print check + "," + tmp[2].strip()
    line = f.readline() 

f.close()
    


