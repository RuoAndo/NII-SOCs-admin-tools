# -*- coding: utf-
import matplotlib.pyplot as plt
import changefinder
import numpy as np
data=np.concatenate([np.random.normal(0.7, 0.05, 300), 
np.random.normal(1.5, 0.05, 300),
np.random.normal(0.6, 0.05, 300),
np.random.normal(1.3, 0.05, 300)])

cf = changefinder.ChangeFinder(r=0.01, order=1, smooth=7)

ret = []
for i in data:
    score = cf.update(i)
    ret.append(score)

fig = plt.figure()
ax = fig.add_subplot(111)
ax.plot(ret)
ax2 = ax.twinx()
ax2.plot(data,'r')
plt.show()
