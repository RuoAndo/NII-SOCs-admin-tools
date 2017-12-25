import sys 
import commands
import numpy as np

#import matplotlib.pyplot as plt


def normalize(v, axis=-1, order=2):
    l2 = np.linalg.norm(v, ord = order, axis=axis, keepdims=True)
    l2[l2==0] = 1
    return v/l2

def test(measured):
    #max_index = measured.index(max(measured))
    #max_index = max(xrange(len(measured)), key=lambda i: measured[i])

    tmp = 0
    local_counter = 0
    max_index = 0
    for x in measured:
        if x > tmp:
            tmp = x
            max_index = local_counter
        local_counter = local_counter + 1

    max_index = local_counter

    #print max_index
    
    split_1 = measured[0:max_index]
    split_2 = measured[max_index+1:-1]

    ## A : [A|B]
    
    f = open('split_1', 'w')
    linecounter = 0
    for i in split_1:
        f.write(str(i) + "\n")
        linecounter = linecounter + 1
    f.close() 
    
    check = commands.getoutput("./main split_1 " + str(linecounter) + " > split_1_filtered")
        #print check

    split_1_KF = []

    f = open('split_1_filtered')
    line = f.readline() 
    while line:
        tmp = line.split(",")
        split_1_KF.append(float(tmp[0]))
        line = f.readline() 
    f.close()

    ## B : [A|B]

    f = open('split_2', 'w')
    linecounter = 0
    for i in split_2:
        f.write(str(i) + "\n")
        linecounter = linecounter + 1
    f.close() 
    
    check = commands.getoutput("./main split_2 " + str(linecounter) + " > split_2_filtered")
        #print check
        
    split_2_KF = []

    f = open('split_2_filtered')
    line = f.readline() 
    while line:
        tmp = line.split(",")
        split_2_KF.append(float(tmp[0]))
        line = f.readline() 
    f.close()
    
    split_KF = split_1_KF +  split_2_KF

    return split_KF
    
argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])
line = f.readline() 
measured = []

while line:
    #tmp = line.split(",")
    #measured.append(float(tmp[0].strip()))
    measured.append(float(line))
    line = f.readline()

f.close()

#print measured

KF = normalize(measured)
#KF = measured

num = 0
while num < 5:
      KF = test(KF)
      num += 1

allPlot3 = {}

counter = 0
for i in KF:
    allPlot3[counter] = i
    counter = counter + 1

print allPlot3
      
f = open(argvs[2])
line = f.readline() 

uName = []
uID = []
while line:
    tmp = line.split("\t")
    uName.append(str(tmp[1]))
    uID.append(int(tmp[0]))
    line = f.readline() 

f.close()

# STEPA: sorting 

titlestr = ""
plotstr = ""
sorted2 = sorted(allPlot3.items(), key=lambda x: float(x[1]), reverse=True)

print "sorted2"
print sorted2

counter2 = 0
for i in sorted2:
        tmp = argvs[1].split("_")

        counter = 0
        for j in uID:

                if int(str(tmp[1])) == j:
                        titlestr = str(tmp[1]) + "," + uName[counter]
                        plotstr = str(tmp[1])
                        print str(i).replace("(","").replace(")","").strip() + "," + titlestr.strip()
                        resultstr = str(i).replace("(","").replace(")","").strip() + "," + titlestr.strip()

                        fname = "kf_" + str(tmp[0]) + "_" + str(tmp[1])
                        f2 = open(fname,'a')
                        f2.write(resultstr)
                        f2.write("\n")
                        f2.close()
                        
                counter = counter + 1
        
        #if counter2 > 10:
        #        break
        
        counter2 = counter2 + 1
