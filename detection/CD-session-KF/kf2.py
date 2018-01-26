import sys 
import commands
import numpy as np

def normalize(v, axis=-1, order=2):
    l2 = np.linalg.norm(v, ord = order, axis=axis, keepdims=True)
    l2[l2==0] = 1
    return v/l2

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])
line = f.readline() 
measured = []

while line:
    tmp = line.split(",")
    measured.append(float(tmp[0].strip()))
    line = f.readline()

#print len(measured)
#print max(measured)
max_index = max(xrange(len(measured)), key=lambda i: measured[i])

#split_1 = measured[0:max_index]
#split_2 = measured[max_index+1:-1]

split_1 = normalize(measured[0:max_index])
split_2 = normalize(measured[max_index+1:-1])

f = open('split_1', 'w')
linecounter = 0
for i in split_1:
    f.write(str(i) + "\n")
    linecounter = linecounter + 1
f.close() 

check = commands.getoutput("./main split_1 " + str(linecounter))
#print check

split_1_list = []

f = open('tmp')
line = f.readline() 
while line:
    tmp = line.split(",")
    split_1_list.append(float(tmp[0]))
    line = f.readline() 
    
f = open('split_2', 'w')
linecounter = 0
for i in split_2:
    f.write(str(i) + "\n")
    linecounter = linecounter + 1
f.close()

check = commands.getoutput("./main split_2 " + str(linecounter))
#print check

split_2_list = []

f = open('tmp')
line = f.readline() 
while line:
    tmp = line.split(",")
    split_2_list.append(float(tmp[0]))
    line = f.readline() 

all = split_1_list + split_2_list
#print all

#x = np.array( [] )
#for i in all:
#    x = np.append( x, i )

#print x
#y = normalize(x)
#all2 = y.tolist()

f = open('data2', 'w')
counter = 0
for i in all:
    f.write(str(measured[counter]) + "," + str(i) + "\n")
    #print str(i)
    counter = counter + 1
f.close()

allPlot2 = []
allPlot3 = {}

counter = 0
for i in all:
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
