import sys 
import commands

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

split_1 = measured[0:max_index]
split_2 = measured[max_index+1:-1]

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

#for i in all:
#    print i

f = open('data2', 'w')
counter = 0
for i in all:
    f.write(str(measured[counter]) + "," + str(i) + "\n")
    print str(i)
    counter = counter + 1
f.close()
