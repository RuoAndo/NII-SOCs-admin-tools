# -*- coding: utf-8 -*-
import numpy as np
import tensorflow as tf
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.utils import shuffle

np.random.seed(0)
tf.set_random_seed(1234)

if __name__ == '__main__':
    def mask(T=200):
        mask = np.zeros(T)
        indices = np.random.permutation(np.arange(T))[:2]
        mask[indices] = 1
        return mask

    def toy_problem(N=10, T=200):
        signals = np.random.uniform(low=0.0, high=1.0, size=(N, T))
        masks = np.zeros((N, T))
        for i in range(N):
            masks[i] = mask(T)

        data = np.zeros((N, T, 2))
        data[:, :, 0] = signals[:]
        data[:, :, 1] = masks[:]
        target = (signals * masks).sum(axis=1).reshape(N, 1)

        return (data, target)

    N = 1000
    T = 200
    maxlen = T

    X, Y = toy_problem(N=N, T=T)
    
    a = []
    for x in Y:
        for z in x:
            a.append(z)

    print Y
            
    mask = []  
    for x in X:
        #for z in x:
            #print z[1]
        mask.append(x[1])

    signal = []  
    for x in X:
        #for z in x:
            #print z[1]
        signal.append(x[0])
            
    #print a

    plt.subplot(3, 1, 1)
    plt.plot(mask)

    plt.subplot(3, 1, 2)
    plt.plot(signal)

    plt.subplot(3, 1, 3)
    plt.plot(a)
    
    #plt.plot(mask)
    #plt.plot(signal)
    #plt.plot( [3,1,4,1,5,9,2,6,5] )
    plt.show()
    
