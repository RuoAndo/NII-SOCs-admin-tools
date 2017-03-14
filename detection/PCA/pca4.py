import sklearn
import pylab
import csv
from sklearn.decomposition import PCA
from sklearn import datasets
import numpy as np
import sys

argvs = sys.argv
#print argvs[1]

data=np.loadtxt(argvs[1],comments='year',delimiter=',',dtype='int32')

pca = PCA(n_components = 2)
pca.fit(data)
x_pca=pca.transform(data)

#print x
print x_pca

#pylab.scatter(x_pca[:,0],x_pca[:,1])
#pylab.show()
