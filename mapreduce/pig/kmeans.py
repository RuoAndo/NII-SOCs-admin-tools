import numpy as np
from sklearn.cluster import KMeans

features = np.loadtxt('tmp', delimiter=',', dtype=int)
print features

kmeans_model = KMeans(n_clusters=3, random_state=10).fit(features)

labels = kmeans_model.labels_

for label, feature in zip(labels, features):
    print(label, feature, feature.sum())
