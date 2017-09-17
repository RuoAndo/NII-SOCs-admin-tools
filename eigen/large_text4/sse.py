import sys
import re
from numpy import *

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])
line = f.readline() 
centroids = []
while line:
    centroids.append(line.strip())
    line = f.readline()
f.close()

f = open(argvs[2])
line = f.readline() 
n1 = []
while line:
    tmp = line.split(",")
    n1.append(tmp[1])
    line = f.readline()
f.close()

f = open(argvs[3])
line = f.readline() 
n2 = []
while line:
    tmp = line.split(",")
    n2.append(tmp[1])
    line = f.readline()
f.close()

counter = 0
sum1 = 0
sum2 = 0
for i in n1:
    sum1 = sum1 + int(i)
    sum2 = sum2 + int(n2[counter])
    counter = counter + 1

counter = 0
sse = 0

f = open('process', 'a')
f.write("### ###" +"\n") 
f.close() 

for i in n1:
    tmpstr1 = str(i).strip() + ":(" + str(float(float(i)/float(sum1))*100).strip() + "%)" 
    tmpstr2 = " < " + str(int(n2[counter])).strip() + ":(" + str(float(float(n2[counter])/float(sum2))*100).strip() + "%)"
    tmpstr3 = ":" + centroids[counter]
    print tmpstr1 + tmpstr2 + tmpstr3

    f = open('process', 'a')
    f.write(tmpstr1+tmpstr2+tmpstr3+"\n") 
    f.close() 

    diffabs = abs(int(i)-int(n2[counter]))
    sse = sse + diffabs
    counter = counter + 1

f = open('SSE', 'a') 
f.write(str(sse)+"\n") 
f.close() 

print "SSE:" + str(sse)
    
