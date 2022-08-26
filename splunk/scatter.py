import numpy as np
import matplotlib.pyplot as plt

import sys
import scipy.stats
from sklearn import preprocessing


ss = preprocessing.StandardScaler()

args = sys.argv

data_set = np.loadtxt(
    fname=args[1],
    dtype="float",
    delimiter=",",
)

x = []
y = []
for data in data_set:
    x.append(data[1])
    y.append(data[2])
    #plt.scatter(preprocessing.minmax_scale(data[1]), preprocessing.minmax_scale(data[2]), marker="x")

xx = preprocessing.minmax_scale(x)
yy = preprocessing.minmax_scale(y)

counter = 0
for xxx in xx:
    plt.scatter(xxx, yy[counter])
    counter = counter + 1

####    

data_set2 = np.loadtxt(
    fname=args[2],
    dtype="float",
    delimiter=",",
)

x2 = []
y2 = []
for data2 in data_set2:
    x2.append(data2[1])
    y2.append(data2[2])
    #plt.scatter(preprocessing.minmax_scale(data[1]), preprocessing.minmax_scale(data[2]), marker="x")

xx2 = preprocessing.minmax_scale(x2)
yy2 = preprocessing.minmax_scale(y2)

counter = 0
for xxx2 in xx2:
    plt.scatter(xxx2, yy2[counter], marker="x")
    counter = counter + 1
    
plt.show()
