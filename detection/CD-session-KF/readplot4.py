#coding:utf-8
# K-means

import numpy as np
import sys
import matplotlib.pyplot as plt

argvs = sys.argv

if __name__ == "__main__":
    data = np.genfromtxt(argvs[1], delimiter=",")
    
    plt.title(argvs[1])
    plt.plot(data[:,1])

    plt.tight_layout() 
    plt.show()  
        
    filename = argvs[1] + ".png"
    plt.savefig(filename)

