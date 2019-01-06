# -*- coding: utf-8 -*-
# coding: UTF-8
import numpy as np
import tensorflow as tf
from sklearn.model_selection import train_test_split
from sklearn.utils import shuffle
import matplotlib.pyplot as plt

np.random.seed(0)
tf.set_random_seed(1234)

if __name__ == '__main__':
    
    def sin(x, T, N ):
        #return np.sin(2.0 * np.pi * x / T)
        return np.sin(N * np.pi * x / T)

    def toy_problem(T, ampl, N, B):
        x = np.arange(0, 2 * T + 1)
        noise = ampl * np.random.uniform(low=-1.0, high=1.0, size=len(x))

        noise2 = []
        for y in noise:
            z = y + B
            noise2.append(z)
        
        return sin(x, T, N) + noise2

    T = 10000
    N = 4    
    f = toy_problem(T, 2, N, 20)

    N = 8
    f2 = toy_problem(T, 0.10, N, 40)

    a = np.arange(0,1)
    
    num = 0
    while num < 3:
        a = a + f + f2 + f2 + f
        num = num + 1
        
    #length_of_sequences = 2 * T  # 全時系列の長さ
    #maxlen = 25  # ひとつの時系列データの長さ

    #data = []
    #target = []

    #for i in range(0, length_of_sequences - maxlen + 1):
    #    data.append(f[i: i + maxlen])
    #    target.append(f[i + maxlen])

    for x in a:
        print x

    print a
        
    #plt.subplot(2, 1, 1)
    plt.plot(a)

    #plt.subplot(2, 1, 2)
    #plt.plot(data[:,1])

    plt.show()  
        
    #filename = argvs[1] + ".png"
    #plt.savefig(filename)
