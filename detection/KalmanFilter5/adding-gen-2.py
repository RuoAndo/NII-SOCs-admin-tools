# coding: UTF-8

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

        #print masks[1,:]
        #print masks
        #print len(masks[1,:])
        #print len(masks[:,1])
        
        for i in range(N):
            masks[i] = mask(T)

        data = np.zeros((N, T, 2))

        #print data
        #print len(data)
        
        data[:, :, 0] = signals[:]
        data[:, :, 1] = masks[:]
        #target = (signals * masks).sum(axis=1).reshape(N, 1)
        target = (signals * masks * 2).sum(axis=1).reshape(N, 1)

        return (data, target)

    '''
    データの生成
    '''
    # N = 10000
    N = 2
    T = 200
    maxlen = T

    X, Y = toy_problem(N=N, T=T)

    #print X[:,:,0]

    #for x in X[:,:,1]:
    #    print x

    f = open('0', 'w')

    constr = ""
    for x in X[:,:,0]:
        for y in x:
            constr = constr + str(y) + "\n"
            print y
            
    f.write(constr)
    f.close()

    f = open('1', 'w')

    constr = ""
    for x in X[:,:,1]:
        for y in x:
            constr = constr + str(y) + "\n"

    f.write(constr)
    f.close()
            
    #print len(Y)
    
    #N_train = int(N * 0.9)
    #N_validation = N - N_train

    #X_train, X_validation, Y_train, Y_validation = \
    #    train_test_split(X, Y, test_size=N_validation)

