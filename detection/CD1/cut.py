import sys
import re
from numpy import *
import math

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])
line = f.readline() 

while line:

    try:
        tmp = line.split(",")
        print tmp[1].rstrip()

    except:
        pass

    line = f.readline()


