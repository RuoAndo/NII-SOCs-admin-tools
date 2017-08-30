# python 1.py tools/libxl/libxl.c libxl 372

import sys 

ulist = []
outdata = []

tpl = []

num = 10034
while num < 10282:
    ulist.append(num)
    outdata.append(0)
    
    num=num+1

#print ulist

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

while line:

    tmp = line.split(",")
    tpl.append(tmp)

    line = f.readline()

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
    comstr = comstr + str(k) + ","

print comstr


