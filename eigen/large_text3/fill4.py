import sys 
import commands
import os
import random

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

clist = []
while line:
    tmp = line.split(",")
    clist.append(int(tmp[0]))
    line = f.readline() 

f.close()

#print clist

olist = []
num = 0
while num < 10:
    olist.append(num)
    num = num + 1

#print olist

li = list(set(olist)-set(clist)) 

#print li

for i in li:

    f2=open("c.rand","r")
    l=f2.readlines()
    s=random.sample(l,1)
    r = "".join(s)
    tmp2 = r.split(',')
    #print tmp2
    f2.close()

    f3=open("c.rand","r")
    l=f3.readlines()
    s=random.sample(l,1)
    r = "".join(s)
    tmp3 = r.split(',')
    #print tmp3
    f3.close()
        
    one = (float(tmp2[1]) + float(tmp3[1])) / 2 + random.uniform(1,100)
    two =  (float(tmp2[2]) + float(tmp3[2])) / 2 + random.uniform(1,100)
    three = (float(tmp2[3]) + float(tmp3[3])) / 2

    print str(i) + "," + str(one) + "," + str(two) + "," + str(three)
          
f = open(argvs[1])

line = f.readline() 
counter = 0
while line:
    tmp = line.split(",")
    print tmp[0] + "," + tmp[1] + "," + tmp[2] + "," + tmp[3].strip()

    counter = counter + 1
    line = f.readline() 
    
