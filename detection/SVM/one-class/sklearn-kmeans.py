import numpy as np
import pandas as pd
from sklearn.cluster import KMeans
import sys
import matplotlib.pyplot as plt

argvs = sys.argv 
data = np.loadtxt(argvs[1],delimiter=",",dtype=float)

#print data[:,1]
#print data[1]

tmp = []

result = KMeans(n_clusters=3).fit_predict(data)
print result

counter = 0
for x in result:
    if x == 0:
        X = data[counter]
        xx = X[0,]
        yy = X[1,]
        plt.scatter(xx,yy,c='red')

    if x == 1:
        X = data[counter]
        xx = X[0,]
        yy = X[1,]
        plt.scatter(xx,yy,c='blue')

    if x == 2:
        X = data[counter]
        xx = X[0,]
        yy = X[1,]
        plt.scatter(xx,yy,c='yellow')
        
    counter = counter + 1

plt.show()
