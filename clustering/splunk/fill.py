import sys
import re
from numpy import *
import commands
from numpy.random import *

argvs = sys.argv
argc = len(argvs)

prev = []

i1 = []
i2 = []
i3 = []

f2 = open(argvs[2])
line2 = f2.readline()

while line2:

    if line2.find("nan") > -1:
    
        f = open(argvs[1])
        line = f.readline()

        counter = 0

        while line:
            tmp = line.split(",")
            #print tmp
            i1.append(tmp[0])
            i2.append(tmp[1])
            i3.append(tmp[2])
            line = f.readline()
            counter = counter + 1

        f.close()

        sum1 = 0
        sum2 = 0
        sum3 = 0

        for var in range(0, 10):
            sum1 = sum1 + float(i1[randint(counter)])
            sum2 = sum2 + float(i2[randint(counter)])
            sum3 = sum3 + float(i3[randint(counter)])

        print str(sum1/10) + "," + str(sum2/10) + "," + str(sum3/10).strip()

    else:
        print line2.strip()

    #print line2
    line2 = f2.readline()
