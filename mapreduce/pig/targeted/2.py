import sys
import re 
import commands
import collections

argvs = sys.argv  

f = open(argvs[1])

line = f.readline() 

anames = []

while line:
    tmp = line.split(",")

    anames.append(tmp[25])
    
    line = f.readline()

count_dict = collections.Counter(anames)
print count_dict.most_common(10)

