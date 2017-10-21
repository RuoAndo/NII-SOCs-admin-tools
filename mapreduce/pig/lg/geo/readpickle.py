import sys
import pickle
import re

argvs = sys.argv
argc = len(argvs)

with open(argvs[1], 'r') as f:
    mydict_load = pickle.load(f)

    

    for i in mydict_load:
        #print mydict_load[i]
        for j in mydict_load[i]:
            #print j + ":" + str(mydict_load[i][j])
            for k in (mydict_load[i][j]):
                print j + "," + k
f.close()

