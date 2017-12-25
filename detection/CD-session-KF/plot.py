import numpy as np
import matplotlib.pyplot as plt

x = np.loadtxt('tmp2', delimiter=',', unpack=True)

plt.plot(x)
plt.show()
