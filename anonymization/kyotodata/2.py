import sys 
import re

argvs = sys.argv
 
f = open(argvs[1])

line = f.readline() 

session = []
while line:
    if len(line) != 2 :
        tmpline = line.replace('(',"").replace(')',"")
        print tmpline.strip()
    
    line = f.readline()
    
f.close


