import numpy as np
import matplotlib.pyplot as plt

x = np.loadtxt('tmp', delimiter=',', unpack=True)

plt.plot(x)

plt.show()
