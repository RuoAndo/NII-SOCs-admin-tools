import sys
import re
from numpy import *

#['1', '1.107591480065538', '706.4975423265975\n']

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])

line = f.readline() 

while line:
    # tmp = line.split("\s+")
    tmp = re.split(r'[\s*]', line)

    catstr = ""
    for i in tmp:

        if i != "":
            catstr = catstr + i + ","

    print catstr.rstrip(",")

    line = f.readline()

f.close()

