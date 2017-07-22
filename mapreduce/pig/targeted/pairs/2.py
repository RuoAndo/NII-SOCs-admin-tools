# python 1.py tools/libxl/libxl.c libxl 372

import sys 
import collections

import re

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

while line:
    tmp = line.split(",")

    alert1 = 0
    alert2 = 0
    alert3 = 0

    #print tmp

    if(len(tmp)==6):
        alert1 = float(tmp[3])/float(tmp[4])

    elif(len(tmp)==9):
        alert1 = float(tmp[3])/float(tmp[4])
        alert2 = float(tmp[6])/float(tmp[7])

    elif(len(tmp)==12):
        alert1 = float(tmp[3])/float(tmp[4])
        alert2 = float(tmp[6])/float(tmp[7])
        alert3 = float(tmp[9])/float(tmp[10])

    elif(len(tmp)>12):
        alert1 = float(tmp[3])/float(tmp[4])
        alert2 = float(tmp[6])/float(tmp[7])
        alert3 = float(tmp[9])/float(tmp[10])
        
    print tmp[0] + "," + tmp[1] + "," + str(alert1) + "," + str(alert2) + "," + str(alert3)

    line = f.readline() 

f.close()

