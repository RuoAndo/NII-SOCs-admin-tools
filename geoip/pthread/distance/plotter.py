import pandas as pd
import matplotlib.pyplot as plt
import sys
import numpy as np

args = sys.argv

data = pd.read_csv(args[1],encoding = 'UTF8')
data

#data.plot.bar()
#data.plot()

data_x = data[data.columns[0]]
data_y = data[data.columns[1]]

#fig = plt.figure()
#ax = fig.add_subplot(1, 1, 1)
#ax.plot(data_x, data_y)
#ax.plot.xlabel(data.columns[0])
#ax.plot.ylabel(data.columns[1])
#ax.tick_params(axis="x", labelrotation=90)

fig, ax = plt.subplots() 

ax.set_xlabel("IP")
ax.set_ylabel("density") 

fig.subplots_adjust()

ticks = 5
plt.xticks(np.arange(0, len(data_x), ticks), data_x[::ticks], rotation=40)
plt.plot(data_x, data_y)

plt.title(args[1])
plt.show()


#plt.xlabel(data.columns[0])
#plt.ylabel(data.columns[1])
#plt.plot(data_x, data_y, linestyle='solid', marker='o')
#plt.show()
