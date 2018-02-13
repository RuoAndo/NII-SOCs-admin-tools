# coding: UTF-8
import numpy as np
import tensorflow as tf
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.utils import shuffle

np.random.seed(0)
tf.set_random_seed(1234)

if __name__ == '__main__':
    def mask(T=20):
        mask = np.zeros(T)
        indices = np.random.permutation(np.arange(T))[:2]
        mask[indices] = 1
        return mask

    def gendata(N=10, T=20):
        signals = np.random.uniform(low=0.0, high=1.0, size=(N, T))
        masks = np.zeros((N, T))
        for i in range(N):
            masks[i] = mask(T)

        data = np.zeros((N, T, 2))
        data[:, :, 0] = signals[:]
        data[:, :, 1] = masks[:]
        target = (signals * masks).sum(axis=1).reshape(N, 1)

        return (data, target)

    N = 10
    T = 20
    maxlen = T

    X, Y = gendata(N=N, T=T)

    N_train = int(N * 0.9)
    N_validation = N - N_train

    X_train, X_validation, Y_train, Y_validation = \
        train_test_split(X, Y, test_size=N_validation)

    signal = []
    for i in X:
        counter = 0
        for j in i:
            signal.append(j[1])

    data = []
    for i in X:
        counter = 0
        for j in i:
            data.append(j[0])

    plt.subplot(2, 1, 1)
    plt.plot(data, label='loss', color='black')
    #plt.show()

    plt.subplot(2, 1, 2)
    plt.plot(signal, label='loss', color='black')
    plt.show()
