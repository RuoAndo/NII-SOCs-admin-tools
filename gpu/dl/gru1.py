# -*- coding: utf-8 -*-
import numpy as np
import tensorflow as tf
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.utils import shuffle

np.random.seed(0)
tf.set_random_seed(1234)


def network_model_output(x, n_batch, maxlen=None, n_hidden=None, n_out=None):
    def weight_variable(shape):
        initial = tf.truncated_normal(shape, stddev=0.01)
        return tf.Variable(initial)

    def bias_variable(shape):
        initial = tf.zeros(shape, dtype=tf.float32)
        return tf.Variable(initial)

    cell = tf.nn.rnn_cell.GRUCell(n_hidden)
    initial_state = cell.zero_state(n_batch, tf.float32)

    state = initial_state
    outputs = []  
    with tf.variable_scope('GRU'):
        for t in range(maxlen):
            if t > 0:
                tf.get_variable_scope().reuse_variables()
            (cell_output, state) = cell(x[:, t, :], state)
            outputs.append(cell_output)

    output = outputs[-1]

    V = weight_variable([n_hidden, n_out])
    c = bias_variable([n_out])
    y = tf.matmul(output, V) + c

    return y


def loss(y, t):
    mse = tf.reduce_mean(tf.square(y - t))
    return mse


def training(loss):
    optimizer = \
        tf.train.AdamOptimizer(learning_rate=0.001, beta1=0.9, beta2=0.999)

    train_op = optimizer.minimize(loss)
    return train_op


if __name__ == '__main__':
    def mask(T=200):
        mask = np.zeros(T)
        indices = np.random.permutation(np.arange(T))[:2]
        mask[indices] = 1
        return mask

    def gen_Data(N=10, T=200):
        signals = np.random.uniform(low=0.0, high=1.0, size=(N, T))
        masks = np.zeros((N, T))
        for i in range(N):
            masks[i] = mask(T)

        data = np.zeros((N, T, 2))
        data[:, :, 0] = signals[:]
        data[:, :, 1] = masks[:]
        target = (signals * masks).sum(axis=1).reshape(N, 1)

        return (data, target)

    N = 10000
    T = 200
    maxlen = T

    X, Y = gen_Data(N=N, T=T)

    N_train = int(N * 0.9)
    N_evaluation = N - N_train

    X_train, X_evaluation, Y_train, Y_evaluation = \
        train_test_split(X, Y, test_size=N_evaluation)

    n_in = len(X[0][0])  # 2
    n_hidden = 100
    n_out = len(Y[0])  # 1

    x = tf.placeholder(tf.float32, shape=[None, maxlen, n_in])
    t = tf.placeholder(tf.float32, shape=[None, n_out])
    n_batch = tf.placeholder(tf.int32, shape=[])

    y = network_model_output(x, n_batch, maxlen=maxlen, n_hidden=n_hidden, n_out=n_out)
    loss = loss(y, t)
    train_op = training(loss)

    history = {
        'val_loss': []
    }

    epochs = 300
    batch_size = 100

    init = tf.global_variables_initializer()
    sess = tf.Session()
    sess.run(init)

    n_batches = N_train // batch_size

    for epoch in range(epochs):
        X_, Y_ = shuffle(X_train, Y_train)

        for i in range(n_batches):
            start = i * batch_size
            end = start + batch_size

            sess.run(train_op, feed_dict={
                x: X_[start:end],
                t: Y_[start:end],
                n_batch: batch_size
            })

        val_loss = loss.eval(session=sess, feed_dict={
            x: X_evaluation,
            t: Y_evaluation,
            n_batch: N_evaluation
        })

        history['val_loss'].append(val_loss)
        print('epoch:', epoch,
              ' evaluation loss:', val_loss)

    loss = history['val_loss']

    #plt.rc('font', family='serif')
    #fig = plt.figure()
    #plt.plot(range(len(loss)), loss, label='loss', color='black')
    #plt.xlabel('epochs')
    #plt.show()
