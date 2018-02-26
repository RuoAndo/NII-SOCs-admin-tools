# coding: UTF-8

import numpy as np
import matplotlib.pyplot as plt

rng = np.random.RandomState(123)

d = 6
N = 10

mean1 = 5
mean2 = 10
mean3 = 15
mean4 = 20
mean5 = 25

x1 = rng.randn(N, d) + np.array([0,0,0,0,0,0])
x2 = rng.randn(N, d) + np.array([mean1, mean1, mean1, mean1, mean1, mean1])
x3 = rng.randn(N, d) + np.array([mean2, mean2, mean2, mean2, mean2, mean2])
x4 = rng.randn(N, d) + np.array([mean3, mean3, mean3, mean3, mean3, mean3])
x5 = rng.randn(N, d) + np.array([mean4, mean4, mean4, mean4, mean4, mean4])
x6 = rng.randn(N, d) + np.array([mean5, mean5, mean5, mean5, mean5, mean5])

x = np.concatenate((x1, x2, x3, x4, x5, x6), axis=0)

for i in x1:
    constr = ""
    for j in i:
        constr = constr + str(j) + ","
    print constr.rstrip(",")

for i in x2:
    constr = ""
    for j in i:
        constr = constr + str(j) + ","
    print constr.rstrip(",")

for i in x3:
    constr = ""
    for j in i:
        constr = constr + str(j) + ","
    print constr.rstrip(",")

for i in x4:
    constr = ""
    for j in i:
        constr = constr + str(j) + ","
    print constr.rstrip(",")

for i in x5:
    constr = ""
    for j in i:
        constr = constr + str(j) + ","
    print constr.rstrip(",")

for i in x6:
    constr = ""
    for j in i:
        constr = constr + str(j) + ","
    print constr.rstrip(",")

    
#print x1
#print x2

#plt.plot(x1, "o")
#plt.plot(x, "o")
#plt.show()

