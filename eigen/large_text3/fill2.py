import sys 
import commands
import os

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

counter = 0
while line:
    tmp = line.split(",")
    #print tmp

    if int(tmp[0]) == counter:
        print tmp[0] + "," + tmp[1] + "," + tmp[2] + "," + tmp[3].strip()

    #elif int(tmp[0]) > counter:
    else:
        #print "HIT:" + str(counter)
        
        try:
            check = commands.getoutput('./avg-random.sh all-conv')
            check2 = commands.getoutput("cat c-rand")
            #print check2

            tmp2 = check2.split(",")
            #print tmp2
            comstr = str(counter) + "," + str(tmp2[1]) + "," + str(tmp2[2]) + "," + str(tmp2[3]).strip()
            print comstr
            #print comstr.replace("\n","")
         
            counter = counter + 1 
            continue

        except:
            #check = commands.getoutput("./avg-random.sh all2")
            #check = commands.getoutput("cat c-rand")
            #print check

            #tmp2 = check.split(",")
        
            #comstr = str(tmp[0]) + "," + str(tmp[1]) + "," + str(tmp2[2]) + "," + str(tmp2[3]) + "," + str(tmp2[1])
            #print comstr.replace("\n","")
            counter = counter + 1
            continue


    counter = counter + 1 

    line = f.readline() 
