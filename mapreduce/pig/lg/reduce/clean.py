import sys
import re
from numpy import *

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])

line = f.readline() 

while line:
    if line.find(")") > -1:
        line2 = line.replace(")","").replace("(","").rstrip()
        tmp = line2.split(",")
        print tmp[0] + "," + tmp[1] + "," + str(int(double(tmp[2]))) + "," + str(int(double(tmp[3]))) + "," + str(int(double(tmp[4]))) 

    line = f.readline() 

f.close()

