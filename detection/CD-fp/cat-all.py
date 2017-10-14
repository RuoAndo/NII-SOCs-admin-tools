import sys 
import os

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])
line = f.readline() 

counter = 0
while line:
    #print line
    f2 = open(line.strip())
    line2 = f2.readline() 

    while line2:
        print str(counter) + "," + line2.strip()
        line2 = f2.readline() 

    counter = counter + 1
    line = f.readline() 

f.close()
    
