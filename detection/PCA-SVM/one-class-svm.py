print(__doc__)

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.font_manager
from sklearn import svm
import sys

xx, yy = np.meshgrid(np.linspace(-5, 5, 500), np.linspace(-5, 5, 500))

argvs = sys.argv
Y = np.loadtxt(argvs[1],delimiter=",",dtype=float)
Y1 = Y[:,0]
Y2 = Y[:,1]

Y1_copy = np.copy(Y1)
Y2_copy = np.copy(Y2)

Y1_std = (Y1_copy - Y1_copy.mean()) / Y1_copy.std()
Y[:,0] = Y1_std

Y2_std = (Y2_copy - Y2_copy.mean()) / Y2_copy.std()
Y[:,1] = Y2_std

print Y

X_train = Y

# fit the model
clf = svm.OneClassSVM(nu=0.1, kernel="rbf", gamma=0.1)
clf.fit(X_train)

y_pred_train = clf.predict(X_train)
n_error_train = y_pred_train[y_pred_train == -1].size

Z = clf.decision_function(np.c_[xx.ravel(), yy.ravel()])
Z = Z.reshape(xx.shape)

plt.title("Novelty Detection")

plt.contourf(xx, yy, Z, levels=np.linspace(Z.min(), 0, 7), cmap=plt.cm.PuBu)

a = plt.contour(xx, yy, Z, levels=[0], linewidths=2, colors='darkred')

s = 40
b1 = plt.scatter(X_train[:, 0], X_train[:, 1], c='white', s=s)
plt.axis('tight')
plt.xlim((-5, 5))
plt.ylim((-5, 5))

plt.show()
