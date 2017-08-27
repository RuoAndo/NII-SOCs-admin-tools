import sys
import re
from numpy import *

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])

line = f.readline() 

while line:
    tmp = line.split(" ")
    print tmp

    line = f.readline() 

f.close()

