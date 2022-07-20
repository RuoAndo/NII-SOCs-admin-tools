import csv
import sys
import matplotlib.pyplot as plt
import numpy as np

args = sys.argv

import csv

filename = args[1]

X = []

with open(filename, encoding='utf8', newline='') as f:
    csvreader = csv.reader(f)
    header = next(f)
    for row in csvreader:
        print(row)

        if int(float(row[3])) < 1250: 
            #A = (row[1], row[2])
            X.append(int(float(row[3])))

      
#plt.hist(X,bins=50)
#plt.hist(X, bins=50, cumulative=True)

fig, ax = plt.subplots()
ax.hist(X,bins=50)

ax.set_xlabel("distance(KM)")
ax.set_ylabel("# of servers")

plt.show()

