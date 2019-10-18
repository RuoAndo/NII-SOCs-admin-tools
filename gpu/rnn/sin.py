# -*- coding: utf-8 -*-

import numpy as np
import tensorflow as tf
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.utils import shuffle

np.random.seed(0)
tf.set_random_seed(1234)

if __name__ == '__main__':
    def sin(x, T=120):
        return np.sin(2.0 * np.pi * x / T)

    def toy_problem(T=100, ampl=0.08):
        x = np.arange(0, 2 * T + 1)
        noise = ampl * np.random.uniform(low=-1.0, high=1.0, size=len(x))
        #print sin(x) + noise

        file = open('sin-out.txt', 'w')
        for i in sin(x) + noise:
            print i
            file.write(str(i) + "\n")

        file.close()
        
        return sin(x) + noise

    T = 720
    f = toy_problem(T)

    length_of_sequences = 2 * T  
    maxlen = 72 

    data = []
    target = []
