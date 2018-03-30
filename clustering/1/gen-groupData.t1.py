# coding: UTF-8

import numpy as np
import matplotlib.pyplot as plt
from numpy.random import *

rng = np.random.RandomState(123)

#d = 6
#N = 10000000

d = 6
N = NCONSTANT

TOTAL = d * N

#rand(100) * 40 + 30 # 30?70の乱数を100個生成
SRC = rand(TOTAL) * 100 + 1 # 30-70の乱数を100個生成
DST = rand(TOTAL) * 100 + 1 # 30-70の乱数を100個生成

#SRC = random_integers(50, TOTAL)# * 20 + 30 # 30-70の乱数を100個生成
#DST = random_integers(50, TOTAL)# * 20 + 30 # 30-70の乱数を100個生成

src = []
for x in SRC:
    src.append(int(x))

dst = []
for x in DST:
    dst.append(int(x))
    
mean = 5

x1 = rng.randn(N, d) * 100 + np.array([0,0,0,0,0,0])
x2 = rng.randn(N, d) * 100 + np.array([mean*2, mean, mean*2, mean, mean*2, mean])
x3 = rng.randn(N, d) * 100 + np.array([mean, mean*2, mean, mean*2, mean, mean*2])

x = np.concatenate((x1, x2, x3), axis=0)

counter = 0

for i in x1:
    constr = ""
    for j in i:
        constr = constr + str(j) + ","
    print str(src[counter]) + "," + str(dst[counter]) + "," + constr.rstrip(",")
    counter = counter + 1
    
for i in x2:
    constr = ""
    for j in i:
        constr = constr + str(j) + ","
    #print constr.rstrip(",")
    print str(src[counter]) + "," + str(dst[counter]) + "," + constr.rstrip(",")
    counter = counter + 1

for i in x3:
    constr = ""
    for j in i:
        constr = constr + str(j) + ","
    print str(src[counter]) + "," + str(dst[counter]) + "," + constr.rstrip(",")
    counter = counter + 1
    #print constr.rstrip(",")
    
#print x1
#print x2

#plt.plot(x1, "o")
#plt.plot(x, "o")
#plt.show()

