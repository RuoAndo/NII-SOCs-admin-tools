import sys
import re
import json

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1], 'r')

lg = {}
line = f.readline()                                                                                                      
while line:
    try:
        tmp = line.split(":")
        lg[tmp[0]] = tmp[1].strip()
    except:
        pass
    line = f.readline()        

#print lg                                                                                              

f.close()

f = open(argvs[2], 'r')

cymon = {}
line = f.readline()                                                                                                      
while line:
    try:
        tmp = line.split(":")
        cymon[tmp[0]] = tmp[1].strip()
    except:
        pass

    line = f.readline()        

#print cymon

for i in lg:
    for j in cymon:
        if str(i)==str(j) and len(lg[i]) > 3:
            print str(i) + "," + lg[i] + "," + "[CyMON]" + cymon[j]

f.close()
