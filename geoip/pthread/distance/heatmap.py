import numpy as np
from matplotlib import pyplot as plt
import pandas as pd

#data = np.loadtxt("tmp", delimiter=",")

#print(data)
df = pd.read_csv('tmp')
print(df['lat'])

plt.scatter(df['lat'], df['lng'], c=df['count'])
plt.colorbar()
plt.show()

#plt.imshow(data, aspect="auto", interpolation = "none")
#plt.colorbar()
#plt.show()
