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
    if counter < 100:
        plt.scatter(xxx, yy[counter],marker="x")
    else:
        plt.scatter(xxx, yy[counter],marker="o")

    counter = counter + 1

plt.show()
