import sys 
import commands
import os
import random

argvs = sys.argv  
argc = len(argvs) 




f = open(argvs[1])

line = f.readline() 

counter = 0
while line:
    tmp = line.split(",")

    print str(counter) + ":" + str(tmp[0])

    if int(tmp[0]) == counter:
        print tmp[0] + "," + tmp[1] + "," + tmp[2] + "," + tmp[3].strip()

    else:        
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

        print str(counter) + "," + str(one) + "," + str(two) + "," + str(three)

        counter = counter + 1
        line = f.readline() 
        continue

        #line = f.readline() 
        #continue

    counter = counter + 1 
    
