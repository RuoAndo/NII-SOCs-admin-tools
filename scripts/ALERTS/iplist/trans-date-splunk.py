import sys
import re

from datetime import datetime as dt

#tstr = '2012-12-29 13:49:37'
#tdatetime = dt.strptime(tstr, '%Y-%m-%d %H:%M:%S')

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])

line = f.readline() 

print "timestamp, tid, ipaddr, tagname"

counter = 0
while line:
    tmp = line.split(",")
    #print dt.strptime(tmp[0], '%Y%m%d')

    print str(dt.strptime(tmp[0],'%Y%m%d')).replace("-","/") + "," + str(counter) + "," + tmp[1] + "," + tmp[2].strip()
    #print line.strip()
    counter = counter + 1
    line = f.readline() 
f.close()
