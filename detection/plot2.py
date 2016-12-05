import numpy as np
import matplotlib.pyplot as plt

from numpy.random import rand, multivariate_normal
data_a = multivariate_normal(rand(1) * 20 - 10, np.eye(1) * (rand()), 250)

plt.plot(data_a)
plt.show()

std = np.std(data_a)
print std

a = []
for i in data_a:
    a.append(i-std)

#print a

plt.plot(a)
plt.show()

nm = data_a/np.linalg.norm(data_a)

plt.plot(nm)
plt.show()
