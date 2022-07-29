import csv
import sys
import matplotlib.pyplot as plt
import numpy as np

args = sys.argv

import csv

filename = args[1]

X = []
X2= []

print(filename)

with open(filename, encoding='utf8', newline='') as f:
    csvreader = csv.reader(f)
    header = next(f)
    for row in csvreader:
        #print(row)

        try:
            if int(float(row[0])) < 1250 and int(float(row[1])) < 1250: 
                #A = (row[1], row[2])
                X.append(int(float(row[0])))
                X2.append(int(float(row[1])))

        except:
            pass

fig = plt.figure()
        
ax1 = fig.add_subplot(2,1,1)
ax1.hist(X,bins=50, label="DNS")
ax1.legend()

ax2 = fig.add_subplot(2,1,2)
ax2.hist(X2,bins=50, label="traceroute")
ax2.legend()


ax1.set_xlabel("distance(KM)")
ax1.set_ylabel("# of servers")

ax2.set_xlabel("distance(KM)")
ax2.set_ylabel("# of servers")

fig.tight_layout()
plt.show()

