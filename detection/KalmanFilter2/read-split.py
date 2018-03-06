# coding: UTF-8
import numpy as np
import tensorflow as tf
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.utils import shuffle
from scipy.ndimage.interpolation import shift

import sys 
import os

np.random.seed(0)
tf.set_random_seed(1234)

if __name__ == '__main__':

    argvs = sys.argv  
    argc = len(argvs) 

    f2 = []

    points = int(argvs[2])
    
    fl = open(argvs[1])
    line = fl.readline() 

    while line:
        f2.append(abs(int(line)))
        line = fl.readline() 

    fl.close()
        
    #for x in f:
    #    f2.append(abs(x))
    
    tmp = {}
    tmp2 = {}

    #counter = 0
    for i in range(len(f2)):
        # print np.argsort(f)[::-1][i], np.sort(f)[::-1][i]
        tmp[np.argsort(f2)[::-1][i]] = np.sort(f2)[::-1][i]
    #    tmp2[counter] = np.argsort(f2)[::-1][i]
        
        #counter = counter + 1
        
    #print tmp
    #print tmp2.sort()
    tmp2 = sorted(tmp.items(), key=lambda x: x[1], reverse=True)

    tmp3 = []
    for var in range(0, points):
        tmp3.append(tmp2[var][0])

    #print tmp3
    tmp3.sort()
    #print tmp3

    point = 0
    counter = 0
    for x in tmp3:
        #if counter < 1:
        #    for y in f[point:x]:
        #        print y
        #    point = x

        fname = str(counter) + ".spl"
        fl = open(fname, 'w')

        concat = ""
        
        for y in f2[point:x]:
            concat = concat + str(y) + "\n"
        point = x
            
        fl.write(concat)
        fl.close()

        counter = counter + 1
            
    #plt.rc('font', family='serif')
    #plt.figure()
    #plt.ylim([-1.5, 1.5])
    #plt.plot(toy_problem(T, ampl=0), linestyle='dotted', color='#aaaaaa')
    #plt.show()
