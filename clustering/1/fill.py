import sys
import re
#from numpy import *
import numpy as np
import commands

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])
line = f.readline() 
while line:
    tmp = line.split(",")

    if line.find("nan") > -1:

        counter = 0
        counter2 = 0
        fl = open(argvs[2])
        line2 = fl.readline() 

        z = np.array( [] )
        while line2:

            if counter % 10000==0:
                tmp2 = line2.split(",")

                tmp3 = tmp2[2:-1]
                x = np.array( [] )

                for y in tmp3:
                    #print y
                    x = np.append( x, y )
                x = np.append( x, float(tmp2[-1]) )
                
                #z = np.append( z, float(tmp2[-1]) )
                z = x
                    
                counter2 = counter2 + 1
                
                #print x
                    
            line2 = fl.readline() 

        #print z

        constr = ""
        for w in z:
            constr = constr + w + ","

        print constr.rstrip(",")
                    
    else:
        #print tmp

        constr = ""
        for w in tmp:
            constr = constr + w + ","

        print constr.rstrip(",").strip()
        
    line = f.readline()
f.close()

