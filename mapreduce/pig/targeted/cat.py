import sys
import re 
import commands

argvs = sys.argv  

f = open(argvs[1])

line = f.readline() 

comstr = "cat "
while line:
    comstr = comstr + line.strip() + " "

    line = f.readline()

comstr = comstr + " > all"
print comstr 
check = commands.getoutput(comstr)
