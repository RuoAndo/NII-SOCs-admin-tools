import sys
import commands

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])

line = f.readline() 

while line:
    tmp = line.split(",")
    print tmp

    comstr = "grep " + tmp[1] + " " + argvs[2] + " | grep " + tmp[2]
    check = commands.getoutput(comstr)
    print check

    line = f.readline()

