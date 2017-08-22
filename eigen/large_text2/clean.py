import sys
import re
from numpy import *

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])

line = f.readline() 

while line:
    if line.find(")") > -1:
        print line.replace(")","").replace("(","").rstrip()

    line = f.readline() 

f.close()

