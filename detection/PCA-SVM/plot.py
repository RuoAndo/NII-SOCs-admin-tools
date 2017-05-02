import numpy as np
import matplotlib.pyplot as plt
import re
ptn = re.compile(r',')

from pylab import *
f = open("tmp", "r")
xlist = list()
ylist = list()
for line in f:
    line2 = line.lstrip()
    #s = line2.split(" ")
    s = ptn.split(line2)
    print s
    xx = s[0]
    yy = s[1][:-1]
    xlist.append(xx)
    ylist.append(yy)
f.close()

plt.scatter(xlist,ylist)
plt.show()



