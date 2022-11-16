import pandas as pd
import matplotlib.pyplot as plt
import sys
import numpy as np

args = sys.argv

#fig = plt.figure()

data1 = pd.read_csv(args[1],encoding = 'UTF8')
data1

data1_x = data1[data1.columns[0]]
data1_y = data1[data1.columns[1]]
#ax1 = fig.add_subplot(2, 1, 1, xscale="log")
#ax = fig.add_subplots(2,2)

fig, ax = plt.subplots(2,2)

ax[0,0].set_title("distance = 0 KM",fontsize=12)
ax[0,0].set_xlabel("IP")
ax[0,0].set_ylabel("density") 
ax[0,0].plot(data1_x, data1_y)

#ax1.set_aspect('equal')

ticks = 20
plt.xticks(np.arange(0, len(data1_x), ticks), data1_x[::ticks], rotation=40, fontsize=10)
#ax[0,0].xticks(np.arange(0, len(data1_x), ticks), data1_x[::ticks], rotation=40, fontsize=10)

####

data2 = pd.read_csv(args[2],encoding = 'UTF8')
data2

data2_x = data2[data2.columns[0]]
data2_y = data2[data2.columns[1]]

#ax2 = fig.add_subplot(2, 1, 2, yscale="log")
#ax[0,1] = fig.add_subplot(2, 2)

ax[0,1].set_title("distance < 500 KM",fontsize=12)
ax[0,1].set_xlabel("IP")
ax[0,1].set_ylabel("density")
ax[0,1].plot(data2_x, data2_y)

#ticks = 5
#plt.xticks(np.arange(0, len(data2_x), ticks), data2_x[::ticks], rotation=40, fontsize=10)

ax[0,1].set_xticks(np.arange(0, len(data2_x), ticks), data2_x[::ticks])
   


####

fig.subplots_adjust()
fig.tight_layout()

#plt.title(args[1])
#fig.show()
plt.show()
