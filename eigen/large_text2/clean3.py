import sys
import re
from numpy import *

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])

line = f.readline() 

while line:
    print line[:-2]
    line = f.readline() 

f.close()

