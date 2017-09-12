import numpy as np
import sys 

argvs = sys.argv  
argc = len(argvs) 

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

    counter = 0
    for i in lr:
        print(str(counter)+","+str(i))
        counter = counter + 1
        
if __name__ == '__main__':
    main()
