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
        return sin(x) + noise

    '''
    データの生成
    '''
    T = 100
    f = toy_problem(T)

    f2 = []
    for x in f:
        f2.append(abs(x))
    
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
    for var in range(0, 4):
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
        
        for y in f[point:x]:
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
