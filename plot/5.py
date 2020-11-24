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

#f = open('1.csv', 'r')
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

#ax = plt.subplot(111)
#ax.plot(x, y, linewidth=1)

#plt.plot(x,y)
#plt.show()

dates = [dateutil.parser.parse(s) for s in x]

plt.subplots_adjust(bottom=0.2)
plt.xticks( rotation= 80 )
ax=plt.gca()
#xfmt = md.DateFormatter('%Y-%m-%d %H:%M:%S')
xfmt = md.DateFormatter('%Y-%m-%d %H:%M')
ax.xaxis.set_major_formatter(xfmt)
#plt.plot(dates[0:10],plt_data[0:10], "o-")
plt.plot(dates,y)
plt.show()
