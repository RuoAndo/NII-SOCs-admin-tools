import sys 
import os

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])
line = f.readline() 

fList = []
while line:
    fList.append(line.strip())
    line = f.readline() 

f.close()

#print fList

wList = []
for j in fList:

    f = open(j)
    line = f.readline() 

    while line:
        tmp = line.split(",")
        wList.append(tmp[0])

        line = f.readline() 
        
wList_uniq = list(set(wList)) 
print wList_uniq

try:
    os.remove("warnlist")
except:
    pass
    
f = open("warnlist", 'a') 
for i in wList_uniq:
    f.write(str(i) + "\n")

f.close()
