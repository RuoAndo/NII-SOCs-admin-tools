from datetime import datetime

import matplotlib.pyplot as plt
import matplotlib.dates as md
import dateutil

import sys
args = sys.argv

x = []
y = []

f = open(args[1], 'r')

line = f.readline()
line = f.readline()

while line:
    tmp = line.split(",")
    dt_object = datetime.fromtimestamp(int(tmp[0]))

    x.append(str(dt_object))
    y.append(int(str(str(tmp[1]).replace('\n',''))))
    
    line = f.readline()    
f.close()

counter = 0
for i in x:
    print(x[counter] + "," + str(y[counter]))
    counter = counter + 1
