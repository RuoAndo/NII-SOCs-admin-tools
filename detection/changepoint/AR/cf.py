import numpy as np
import matplotlib.pyplot as plt
import changefinder

data = np.loadtxt('tmp', delimiter=',', unpack=True)

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


