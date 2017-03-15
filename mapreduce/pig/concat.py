import sys
import commands

argvs = sys.argv
 
f = open(argvs[1])

line = f.readline() 

comstr = ""
while line:
    comstr = comstr + " " + line.strip()

    line = f.readline()

comstr = "cat" + comstr + " > part-all"
check = commands.getoutput(comstr)
