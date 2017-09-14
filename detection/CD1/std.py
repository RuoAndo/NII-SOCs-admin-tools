import numpy as np
import sys 

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[3])

line = f.readline() 

instid = []
instname = []
while line:
    tmp = line.split("\t")
    instid.append(tmp[0])
    instname.append(tmp[1])
    line = f.readline()

f.close()

f = open(argvs[1])

line = f.readline() 

l = np.array([])
while line:
    tmp = line.split(",")
    l = np.append( l, float(tmp[1]) )
    line = f.readline()

def main():
    std = np.std(l)                 
    lr = l / np.linalg.norm(l)  
    #print(lr)

    tmp = str(argvs[2]).split("-")

    counter = 0
    for i in instid:
        if int(i) == int(tmp[1]):
            uname = instname[counter]
        counter = counter + 1
            
    counter = 0
    for i in lr:
        print(str(counter)+","+str(i))+","+str(tmp[1])+","+uname.strip()
        counter = counter + 1
        
if __name__ == '__main__':
    main()
