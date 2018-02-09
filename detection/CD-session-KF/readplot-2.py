#coding:utf-8
# K-means

import numpy as np
import sys
import matplotlib.pyplot as plt

argvs = sys.argv

if __name__ == "__main__":
    data = np.genfromtxt(argvs[1])
    data2 = np.genfromtxt(argvs[2],delimiter=",")
    #print(data2[3:-1])

    plt.subplot(2, 1, 1)
    plt.plot(data)

    #lstm = []
    #for x in data2[3:-1]:
    #    for y in x:
    #        lstm.append(y)

    #print(lstm)

    plt.subplot(2, 1, 2)
    plt.plot(data2[:,2])

    plt.show()  
        
    filename = argvs[1] + ".png"
    plt.savefig(filename)

