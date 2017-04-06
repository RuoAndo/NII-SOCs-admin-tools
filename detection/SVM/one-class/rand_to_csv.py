import sys 
import re

argvs = sys.argv

f = open(argvs[1])

line = f.readline() 

while line:
    tmp = line.strip("\[").strip("\[").strip()
    tmp2 = tmp.split(" ")
    print str(tmp2).replace("[","").replace("]","").replace("'","")

    
    line = f.readline()

f.close

