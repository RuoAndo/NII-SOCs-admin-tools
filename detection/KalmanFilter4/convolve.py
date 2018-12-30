# -*- coding: utf-8 -*-
import numpy as np
import matplotlib.pyplot as plt


x=np.linspace(0,20,100)
yorg=np.sin(x)
y=np.sin(x)+np.random.randn(100)*0.2

for i in y:
    print(i)

num=5
b=np.ones(num)/num

y2=np.convolve(y, b, mode='same')

#plt.plot(x,yorg,'r',label='sin')
plt.plot(x,y,'k-',label='org')
#plt.plot(x,y2,'b--', label='ma')
plt.show()
