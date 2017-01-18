import sklearn
import pylab
from sklearn.decomposition import PCA
from sklearn import datasets

iris = datasets.load_iris()
x = iris.data
y = iris.target

pca = PCA(n_components = 2)
pca.fit(x)
x_pca=pca.transform(x)

#print x
print x_pca

pylab.scatter(x_pca[:,0],x_pca[:,1])
pylab.show()
