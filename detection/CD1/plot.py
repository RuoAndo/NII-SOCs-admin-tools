import numpy as np
import matplotlib.pyplot as plt
import sys

argvs = sys.argv

x = np.loadtxt(argvs[1], delimiter=',', unpack=True)
plt.plot(x)

plt.show()
