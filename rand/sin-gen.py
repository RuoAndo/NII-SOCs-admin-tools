# coding: UTF-8
import numpy as np
import tensorflow as tf
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.utils import shuffle
from scipy.ndimage.interpolation import shift

np.random.seed(0)
tf.set_random_seed(1234)

if __name__ == '__main__':
    def sin(x, T=100):
        return np.sin(2.0 * np.pi * x / T)

    def toy_problem(T=100, ampl=0.05):
        x = np.arange(0, 2 * T + 1)
        noise = ampl * np.random.uniform(low=-1.0, high=1.0, size=len(x))
        return sin(x) # + noise

    '''
    データの生成
    '''
    T = 100
    f = toy_problem(T)

    y = shift(f, 1)

    counter = 0
    for x in f:
        d = x - y[counter]

        if d > 0:
            print("1")
        else:
            print ("-1")
        counter = counter + 1
        
    '''
    グラフで可視化
    '''
    #plt.rc('font', family='serif')
    #plt.figure()
    #plt.ylim([-1.5, 1.5])
    #plt.plot(toy_problem(T, ampl=0), linestyle='dotted', color='#aaaaaa')
    #plt.show()
