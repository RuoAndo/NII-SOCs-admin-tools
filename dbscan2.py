import numpy as np
import matplotlib.pyplot as mpl
from scipy.spatial import distance
from sklearn.cluster import DBSCAN

moss1 = np.random.randn(100, 2) + 5
moss2 = np.random.randn(50, 2)

r1 = np.random.uniform(low=-10, high=10, size=100)
r2 = np.random.uniform(low=-10, high=10, size=100)
r3 = np.column_stack([r1, r2])

data = np.vstack([moss1, moss2, r3])

# data
# * * * * * * * *
# * * * * * 1 1 *
# * * * * * * 1 *
# * * 2 * * * * *
# * 2 2 * * * * *
# * * * * * * * *

db = DBSCAN().fit(data)
labels = db.labels_

dbc1 = data[labels == 0] 
dbc2 = data[labels == 1] 
noise = data[labels == -1] 

x1, x2 = -12, 12
y1, y2 = -12, 12
fig = mpl.figure()
fig.subplots_adjust(hspace=0.1, wspace=0.1)

# plot original (correct)
org1 = fig.add_subplot(121, aspect='equal')
org1.scatter(moss1[:, 0], moss1[:, 1], lw=0.5, color='#f781bf')
org1.scatter(moss2[:, 0], moss2[:, 1], lw=0.5, color='#028E9B')
org1.scatter(r3[:, 0], r3[:, 1], lw=0.5, color='#ff7f00')
org1.xaxis.set_visible(False)
org1.yaxis.set_visible(False)
org1.set_xlim(x1, x2)
org1.set_ylim(y1, y2)
org1.text(-11, 10, 'original: m1, m2, rand)')

# plot DBScan fitted
dbscn2 = fig.add_subplot(122, aspect='equal')
dbscn2.scatter(dbc1[:, 0], dbc1[:, 1], lw=0.5, color='#f781bf')
dbscn2.scatter(dbc2[:, 0], dbc2[:, 1], lw=0.5, color='#028E9B')
dbscn2.scatter(noise[:, 0], noise[:, 1], lw=0.5, color='#ff7f00')
dbscn2.xaxis.set_visible(False)
dbscn2.yaxis.set_visible(False)
dbscn2.set_xlim(x1, x2)
dbscn2.set_ylim(y1, y2)
dbscn2.text(-11, 10, 'DBScan fitted')

fig.savefig('image.png', bbox_inches='tight')
