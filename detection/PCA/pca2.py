import numpy as np
import matplotlib.pyplot as plt

np.random.seed(0)
xmin = -10
xmax =  10
ymin = -10
ymax =  10

mu = [2,2]
cov = [[3,2.3],[1.8,3]]

x, y = np.random.multivariate_normal(mu,cov,1000).T

av_x = np.average(x)
av_y = np.average(y)

S = np.cov(x, y)
print "S", S

la, v = np.linalg.eig(S)

print "la", la
print "v", v

x2 = x - av_x
y2 = y - av_y

a1 = np.array([np.dot(v, [x2[i],y2[i]]) for i in range(len(x))])

#plt.figure(figsize=(8, 13))

plt.subplot(211)
plt.xlim(xmin, xmax)
plt.ylim(ymin, ymax)
#plt.scatter(x, y, alpha=0.5, zorder=100)
plt.scatter(x, y)
plt.plot([0, 0], [ymin, ymax], "k")
plt.plot([xmin, xmax], [0, 0], "k")
#plt.show()

plt.subplot(212)
plt.xlim(xmin, xmax)
plt.ylim(ymin, ymax)
#plt.scatter(a1[:,0], a1[:,1], c="r", alpha=0.5, zorder=100)
plt.scatter(a1[:,0], a1[:,1], c="r")
plt.plot([0, 0], [ymin, ymax], "k")
plt.plot([xmin, xmax], [0, 0], "k")
plt.show()
