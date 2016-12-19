import matplotlib.pyplot as plt
#import changefinder
import numpy as np
data=np.concatenate([np.random.normal(0.7, 0.05, 300),
np.random.normal(1.5, 0.05, 300),
np.random.normal(0.6, 0.05, 300),
np.random.normal(1.3, 0.05, 300)])

for i in data:
    print i

#plt.plot(data)
#plt.show()
