# -*- coding: utf-8 -*-

import os
import re
import io
import requests
import numpy as np
import matplotlib.pyplot as plt
import tensorflow as tf
from time import sleep

from zipfile import ZipFile
from tensorflow.python.framework import ops
ops.reset_default_graph()

import sys
import time
import datetime
from datetime import datetime
        
argvs = sys.argv  
argc = len(argvs) 

if (argc != 3):   
    print 'Usage: # python %s filename epoch' % argvs[0]
    quit()         

sess = tf.Session()

epochs = int(argvs[2])
batch_size = 250
max_sequence_length = 25
rnn_size = 10
embedding_size = 50
min_word_freq = 10
learning_rate = 0.0005
dropout_keep_prob = tf.placeholder(tf.float32)

# Download or open data
data_dir = 'temp'
data_file = 'text_data.txt'
if not os.path.exists(data_dir):
    os.makedirs(data_dir)

f = open(argvs[1])
line = f.readline() 

text_data = []

while line:
    text_data.append(line.replace("."," "))
    line = f.readline()

text_data = [x.split('\t') for x in text_data if len(x)>=1]

[text_data_label, text_data_train] = [list(x) for x in zip(*text_data)]

def clean_text(text_string):
    text_string = re.sub(r'([^\s\w]|_|[0-9])+', '', text_string)
    text_string = " ".join(text_string.split())
    text_string = text_string.lower()
    return(text_string)

text_data_train = [clean_text(x) for x in text_data_train]

# backup
f = open('text.txt', 'w') 
f.write(str(text_data_train)) 
f.close() 

vocab_processor = tf.contrib.learn.preprocessing.VocabularyProcessor(max_sequence_length,
                                                                     min_frequency=min_word_freq)
text_processed = np.array(list(vocab_processor.fit_transform(text_data_train)))

#text_processed
#[[ 44 455   0 ...   0   0   0]
#  [ 47 315   0 ...   0   0   0]
#  [ 46 465   9 ...   0 368   0]
#  ...
#  [  0  59   9 ...   0   0   0]
#  [  5 493 108 ...   1 198  12]
#  [  0  40 474 ...   0   0   0]]

text_processed = np.array(text_processed)
text_data_label = np.array([1 if x=='tagged' else 0 for x in text_data_label])

shuffled_ix = np.random.permutation(np.arange(len(text_data_label)))
x_shuffled = text_processed[shuffled_ix]
y_shuffled = text_data_label[shuffled_ix]

# Split train/test set with 80% and 20%.

ix_cutoff = int(len(y_shuffled)*0.80)
x_train, x_test = x_shuffled[:ix_cutoff], x_shuffled[ix_cutoff:]
y_train, y_test = y_shuffled[:ix_cutoff], y_shuffled[ix_cutoff:]
vocab_size = len(vocab_processor.vocabulary_)
print("Vocabulary Size: {:d}".format(vocab_size))
print("80-20 Train Test split: {:d} -- {:d}".format(len(y_train), len(y_test)))

# placeholders
x_data = tf.placeholder(tf.int32, [None, max_sequence_length])
y_output = tf.placeholder(tf.int32, [None])

# embedding
embedding_mat = tf.Variable(tf.random_uniform([vocab_size, embedding_size], -1.0, 1.0))
embedding_output = tf.nn.embedding_lookup(embedding_mat, x_data)

# RNN cell
if tf.__version__[0]>='1':
    cell=tf.contrib.rnn.BasicRNNCell(num_units = rnn_size)
else:
    cell = tf.nn.rnn_cell.BasicRNNCell(num_units = rnn_size)

output, state = tf.nn.dynamic_rnn(cell, embedding_output, dtype=tf.float32)
output = tf.nn.dropout(output, dropout_keep_prob)

# RNN sequence
output = tf.transpose(output, [1, 0, 2])
final = tf.gather(output, int(output.get_shape()[0]) - 1)

weight = tf.Variable(tf.truncated_normal([rnn_size, 2], stddev=0.1))
bias = tf.Variable(tf.constant(0.1, shape=[2]))
logits_out = tf.matmul(final, weight) + bias

# Loss function with logits
losses = tf.nn.sparse_softmax_cross_entropy_with_logits(logits=logits_out, labels=y_output)
loss = tf.reduce_mean(losses)

accuracy = tf.reduce_mean(tf.cast(tf.equal(tf.argmax(logits_out, 1), tf.cast(y_output, tf.int64)), tf.float32))
optimizer = tf.train.RMSPropOptimizer(learning_rate)
train_step = optimizer.minimize(loss)

init = tf.global_variables_initializer()
sess.run(init)

train_loss = []
test_loss = []
train_accuracy = []
test_accuracy = []
# Start training
for epoch in range(epochs):

    # Shuffle training data
    shuffled_ix = np.random.permutation(np.arange(len(x_train)))
    x_train = x_train[shuffled_ix]
    y_train = y_train[shuffled_ix]
    num_batches = int(len(x_train)/batch_size) + 1

    # batch
    for i in range(num_batches):

        min_ix = i * batch_size
        max_ix = np.min([len(x_train), ((i+1) * batch_size)])
        x_train_batch = x_train[min_ix:max_ix]
        y_train_batch = y_train[min_ix:max_ix]
        
        # Run train step
        train_dict = {x_data: x_train_batch, y_output: y_train_batch, dropout_keep_prob:0.5}
        sess.run(train_step, feed_dict=train_dict)
        
    # Run loss and accuracy for training
    temp_train_loss, temp_train_acc = sess.run([loss, accuracy], feed_dict=train_dict)
    train_loss.append(temp_train_loss)
    train_accuracy.append(temp_train_acc)
    
    # Run loss and accuracy for test
    test_dict = {x_data: x_test, y_output: y_test, dropout_keep_prob:1.0}
    temp_test_loss, temp_test_acc = sess.run([loss, accuracy], feed_dict=test_dict)
    test_loss.append(temp_test_loss)
    test_accuracy.append(temp_test_acc)
    print('Epoch: {}, Test Loss: {:.2}, Test Acc: {:.2}'.format(epoch+1, temp_test_loss, temp_test_acc))
    
# Plot loss over time
epoch_seq = np.arange(1, epochs+1)
plt.plot(epoch_seq, train_loss, 'k--', label='Train Set')
plt.plot(epoch_seq, test_loss, 'r-', label='Test Set')
plt.title('Softmax Loss')
plt.xlabel('Epochs')
plt.ylabel('Softmax Loss')
plt.legend(loc='upper left')
#plt.show()
plt.savefig('1.png')
plt.clf()

# Plot accuracy over time
plt.plot(epoch_seq, train_accuracy, 'k--', label='Train Set')
plt.plot(epoch_seq, test_accuracy, 'r-', label='Test Set')
plt.title('Test Accuracy')
plt.xlabel('Epochs')
plt.ylabel('Accuracy')
plt.legend(loc='upper left')
#plt.show()
plt.savefig('2.png')
