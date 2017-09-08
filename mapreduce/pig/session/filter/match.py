import sys
import re
from numpy import *

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])
line = f.readline() 

uid = []
uname = []
while line:
    #print line
    tmp = line.split("\t")
    #print tmp[0]
    uid.append(tmp[0])
    uname.append(tmp[1])
    line = f.readline() 

f.close()

#print uid
#print uname

f = open(argvs[2])
line = f.readline() 

while line:
    tmp = line.split(",")
    #print tmp

    if len(tmp[1]) > 0:
        counter = 0
        for i in uid:
            if int(i) == int(tmp[1]):
                #print uname[counter] + ":" + line
                constr = tmp[0] + "," + uname[counter].strip() + "," + tmp[2] + "," + tmp[3] + "," + tmp[4] + "," + tmp[5] + "," + tmp[6].lstrip(' ')
                print constr.strip()
            counter = counter + 1

    if len(tmp[3]) > 0:
        counter = 0
        for i in uid:
            if int(i) == int(tmp[3]):
                #print uname[counter] + ":" + line
                constr = tmp[0] + "," + tmp[1] + "," + tmp[2] + "," + uname[counter].strip() + "," + tmp[4] + "," + tmp[5] + ", " + tmp[6].lstrip()
                print constr.strip()
            counter = counter + 1

    line = f.readline() 
