from datetime import datetime

#import matplotlib.pyplot as plt
#import matplotlib.dates as mdates

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

dates = [dateutil.parser.parse(s) for s in x]

plt.subplots_adjust(bottom=0.2)
plt.xticks( rotation= 80 )
ax=plt.gca()

xfmt = md.DateFormatter('%Y-%m-%d %H:%M')
ax.xaxis.set_major_formatter(xfmt)
plt.plot(dates,y)
plt.show()
