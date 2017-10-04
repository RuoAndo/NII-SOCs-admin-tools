import sys 
import os

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])
line = f.readline() 

wList = {}
counter = 0
while line:
    wList[counter]=line.strip()
    counter = counter + 1

    line = f.readline()
f.close()


f = open(argvs[2])
line = f.readline() 

counter = 0
while line:
    tmp = line.split(",")
    print wList[int(tmp[0])] + "," + tmp[1] + "," + tmp[2].strip()
    line = f.readline() 
f.close()


    

