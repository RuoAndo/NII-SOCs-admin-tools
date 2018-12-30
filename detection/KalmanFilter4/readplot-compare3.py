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
    data2 = np.genfromtxt(argvs[2], delimiter=",")

    plt.subplot(2, 1, 1)
    plt.plot(data[:,1])

    plt.subplot(2, 1, 2)
    plt.plot(data2[:,1])

    plt.show()  
        


