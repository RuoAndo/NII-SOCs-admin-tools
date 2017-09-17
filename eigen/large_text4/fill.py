import sys
import re
from numpy import *
import commands

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])
line = f.readline() 
n1 = []
while line:
    tmp = line.split(",")
    n1.append(tmp[1])
    line = f.readline()
f.close()

#print n1

counter = 0
f = open(argvs[2])
line = f.readline() 
while line:
    tmp = line.split(",")
    if int(n1[counter]) == 0 and line.find("nan") == -1:
        argstr =  tmp[0] + " " + tmp[1] + " " + tmp[2].strip()
        comstr = "./fill " + argstr + " 500000 6" 
        #print comstr
        check = commands.getoutput("./fill " + argstr + " 500000 6")
        # print chec
        #print n1[counter].strip() + "," + check.strip()
        print check.strip()

    if line.find("nan") > -1:
        #print "nan" + str(tmp)
        argstr =  "1" + " " + "1" + " " + "1".strip()
        comstr = "./fill " + argstr + " 500000 6" 
        #print "com:" + comstr
        check = commands.getoutput(comstr)
        #print check
        #print n1[counter].strip() + "," + check.strip()
        print check.strip()

    if int(n1[counter]) > 0:
        #print n1[counter].strip() + "," + line.strip()
        print line.strip()

    line = f.readline()
    counter = counter + 1
f.close()



    
