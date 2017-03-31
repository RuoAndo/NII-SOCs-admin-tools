import sys 
import socket, struct
import numpy as np
import matplotlib.pyplot as plt

Y = np.loadtxt("tmp",delimiter=",",dtype=float)
dstIP = Y[:,2]
srcIP = Y[:,3]

dstIP_copy = np.copy(dstIP)
srcIP_copy = np.copy(srcIP)

dstIP_std = (dstIP_copy - dstIP_copy.mean()) / dstIP_copy.std()
#Y[:,2] = dstIP_std

srcIP_std = (srcIP_copy - srcIP_copy.mean()) / srcIP_copy.std()
#Y[:,3] = srcIP_std

#for x in Y.tolist():
#    x_str = map(str,x)
#    print ",".join(x_str) 

x = Y[:,2] 
y = Y[:,3] 

#Z = np.c_[x, y]
Z = np.c_[Y[:,2], Y[:,3]]
#print Z

for x in Z.tolist():
    x_str = map(str,x)
    #print "test"
    print ",".join(x_str) 

#plt.scatter(x,y)
#plt.show()

