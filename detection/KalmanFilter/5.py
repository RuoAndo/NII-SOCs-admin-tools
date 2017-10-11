# python 1.py tools/libxl/libxl.c libxl 372

import sys 

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

measured = []

while line:
    tmp = line.split(",")
    measured.append(float(tmp[0].strip()))
    line = f.readline()

print len(measured)
    
print max(measured)
max_index = max(xrange(len(measured)), key=lambda i: measured[i])

split_1 = measured[0:max_index]
split_2 = measured[max_index+1:-1]

f = open('split_2', 'w')
for i in split_2:
    f.write(str(i) + "\n")
f.close() 



