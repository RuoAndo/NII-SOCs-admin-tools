import sklearn
import pylab
import csv
from sklearn.decomposition import PCA
from sklearn import datasets

import sys
argvs = sys.argv

import numpy as np
data=np.loadtxt(argvs[1],delimiter=',',dtype='float')

pca = PCA(n_components = 2)
pca.fit(data)
x_pca=pca.transform(data)

#print x
print x_pca

pylab.scatter(x_pca[:,0],x_pca[:,1])
pylab.show()
