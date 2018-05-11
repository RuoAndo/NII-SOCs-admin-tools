import sys
import re

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])

line = f.readline() 

counter = 0
while line:
    tmp = line.split(",")

    if counter > 1:
        print tmp[0].replace("\"","")

    counter = counter + 1

    line = f.readline() 
f.close()
