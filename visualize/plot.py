import numpy as np
import matplotlib.pyplot as plt

x, y = np.loadtxt('tmp2', delimiter=',', unpack=True)

plt.scatter(x, y)

plt.show()
