# python 1.py tools/libxl/libxl.c libxl 372

import sys 
argvs = sys.argv  
argc = len(argvs) 

ulist = []
outdata = []

tpl = []

f2 = open(argvs[2])

line2 = f2.readline() 

while line2:
    
    tmp = line2.split("\t")
    ulist.append(tmp[0])
    outdata.append(0)    

    line2 = f2.readline()
    
#print ulist

f = open(argvs[1])

line = f.readline() 

while line:

    tmp = line.split(",")
    tpl.append(tmp)

    line = f.readline()

#print tpl
    
fl = list(sorted(tpl, key=lambda tpl: int(tpl[2]), reverse=True))

RANKING = 0
for i in fl:
    #print i

    counter = 0
    for j in ulist:
        if str(i[1]) == str(j):
            #print "HIT"
            #print i
            #print ulist[counter]
            outdata[counter] = 1
        counter = counter + 1
        
    RANKING = RANKING + 1
    #print RANKING

    if RANKING > 5:
        break

comstr = ""
for k in outdata:
    comstr = comstr + str(k) + " "

print comstr


