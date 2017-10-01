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
    dst.append(tmp[0])

    line = f.readline()

f.close()

#print src
src_dict = {}
dst_dict = {}

for i in src:
    src_dict[i] = 0

for i in dst:
    dst_dict[i] = 0

#print src_dict
    
f = open(argvs[2])
line = f.readline() 

counter = 0
counter_bk = 1
first_counter = 0

while line:
    tmp = line.split(",")
    
    counter = int(tmp[0])
    
    for i in src:
        if int(str(tmp[1]))==int(i):
            src_dict[i] = int(tmp[3])

    for i in src:
        if int(str(tmp[2]))==int(i):
            dst_dict[i] = int(tmp[3])
            
    line = f.readline()

    if counter != counter_bk: 
        counter_bk = counter

        for i in src_dict:
            tmpstr = str(i) + "," + str(src_dict[i])
            f2 = open("outward-" + i, 'a') 
            f2.write(tmpstr + "\n") 
            f2.close()

        for i in dst_dict:
            tmpstr = str(i) + "," + str(dst_dict[i])
            f2 = open("inward-" + i, 'a') 
            f2.write(tmpstr + "\n") 
            f2.close() 

            
f.close()




            
            

