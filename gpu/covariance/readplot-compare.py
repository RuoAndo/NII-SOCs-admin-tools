#coding:utf-8
# K-means

import numpy as np
import sys
import matplotlib.pyplot as plt
from scipy.ndimage.interpolation import shift

argvs = sys.argv

def zscore(x, axis = None):
    xmean = x.mean(axis=axis, keepdims=True)
    xstd  = np.std(x, axis=axis, keepdims=True)
    zscore = abs((x-xmean)/xstd)
    return zscore

if __name__ == "__main__":
    data = np.genfromtxt(argvs[1], delimiter=",")

    plt.subplot(3, 1, 1)
    plt.plot(data[:,0])

    plt.subplot(3, 1, 2)
    plt.plot(data[:,1])

    plt.subplot(3, 1, 3)
    plt.plot(data[:,2])
    
    y = shift(data[:,1],1)

    z = []
    c = 0
    
    #for w in data[:,1]:            
        #tmp = w - y[c]
        #z.append(tmp)
        #c = c + 1

    #plt.subplot(3, 1, 3)
    #plt.plot(zscore(np.array(z)))

    plt.show()  
        


