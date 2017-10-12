import sys 
import os
import commands

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])
line = f.readline() 

while line:
    tmp = line.split("_")
    print tmp
    dststr = tmp[0].replace(".","").replace("/","") + tmp[3] + ".csv"

    comstr = "rm -rf " + dststr
    check = commands.getoutput(comstr)

    comstr = "cp " + line.strip() + " "  + dststr
    print comstr
    check = commands.getoutput(comstr)
    #print check

    line = f.readline() 
f.close()

