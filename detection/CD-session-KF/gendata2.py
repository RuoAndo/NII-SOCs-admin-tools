# python 1.py tools/libxl/libxl.c libxl 372

import sys 

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])
line = f.readline() 

src = []
dst = []

while line:
    tmp = line.split("\t")
    src.append(tmp[0])
    dst.append(tmp[1])

    line = f.readline()

f.close()

#print src
src_dict = {}
dst_dict = {}

for i in src:
    src_dict[i] = 0

for i in dst:
    dst_dict[i] = 0

print src_dict
print dst_dict
    




            
            

