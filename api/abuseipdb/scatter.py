import numpy as np
import matplotlib.pyplot as plt

import sys
args = sys.argv
data_set = np.loadtxt(
    fname=args[1],
    dtype="float",
    delimiter=",",
)

for data in data_set:
    plt.scatter(data[0], data[1])

plt.title("abuseIPDB:"+args[1])
plt.xlabel("countryCode")
plt.ylabel("usageType")
plt.grid()

plt.show()
