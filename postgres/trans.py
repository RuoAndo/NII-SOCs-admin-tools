import sys 
import re

argvs = sys.argv  
argc = len(argvs)

f = open(argvs[1])

counter = 0
line = f.readline() 
while line:
    line = re.sub(r'\s+', ",", line)
    tmp = line.split(",")

    try:
        print tmp[2] + "," + tmp[3]
    except:
        pass
        
    line = f.readline()





