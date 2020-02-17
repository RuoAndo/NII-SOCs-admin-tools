# -*- coding:utf-8 -*-
#!/usr/bin/env python3

import tensorflow as tf
import numpy as np
import matplotlib.pyplot as plt
import time

sess = tf.InteractiveSession()

x = sess.run(tf.random_normal(shape=[100,300],mean=0.0,stddev=1.0,dtype=tf.float32))
y = sess.run(tf.random_normal(shape=[300,100],mean=0.0,stddev=1.0,dtype=tf.float32))

c = tf.matmul(x, y)

print(sess.run(c))

config = tf.ConfigProto()
config.allow_soft_placement = True
sess_soft = tf.Session(config=config)

config.gpu_options.allow_growth = True
sess_grow = tf.Session(config=config)

config.gpu_options.per_process_gpu_memory_fraction = 0.4
sess_limited = tf.Session(config=config)

start = time.time()

if tf.test.is_built_with_cuda():
    with tf.device('/cpu:0'):
        a = sess.run(tf.random_normal(shape=[1,45000],mean=0.0,stddev=1.0,dtype=tf.float32))
        b = sess.run(tf.random_normal(shape=[45000,1],mean=0.0,stddev=1.0,dtype=tf.float32))

        with tf.device('/gpu:0'):
            c = tf.matmul(a,b)
            c = tf.reshape(c, [-1])
        
        with tf.device('/gpu:1'):
            d = tf.matmul(b,a)
            flat_d = tf.reshape(d, [-1])
            
        combined = tf.multiply(c, flat_d)

    print(sess.run(c))
    print(sess.run(d))
    print(sess.run(combined))

process_time = time.time() - start
print(str(process_time) + " sec")


