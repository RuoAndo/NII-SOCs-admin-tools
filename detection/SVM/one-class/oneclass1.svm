print(__doc__)

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.font_manager
from sklearn import svm
from sklearn.svm import SVC
from sklearn.preprocessing import StandardScaler
from matplotlib.colors import ListedColormap


import re
ptn = re.compile(r'\s+')

xx, yy = np.meshgrid(np.linspace(-5, 5, 500), np.linspace(-5, 5, 500))
X = 0.3 * np.random.randn(100, 2)
X_train = np.r_[X + 2, X - 2]

f = open("tmp", "r")
xlist = list()
ylist = list()
for line in f:
    line2 = line.lstrip()
    #s = line2.split(" ")
    s = ptn.split(line2)
    #print s
    xxx = s[0]
    yyy = s[1][:-1]
    xlist.append(xxx)
    ylist.append(yyy)
f.close()

XX = np.array(xlist)
YY = np.array(ylist)

X_train = np.c_[XX, YY]

clf = svm.OneClassSVM(nu=0.1, kernel="rbf", gamma=0.1)
clf.fit(X_train)
y_pred_train = clf.predict(X_train)

print X_train
print y_pred_train
