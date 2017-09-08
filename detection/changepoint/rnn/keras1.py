import numpy as np
import matplotlib.pyplot as plt
from keras.models import Sequential
from keras.layers.core import Dense, Activation
from keras.layers.recurrent import SimpleRNN
from keras.optimizers import Adam
from keras.callbacks import EarlyStopping
from sklearn.model_selection import train_test_split
from sklearn.utils import shuffle

import sys 
import numpy as np
import re

argvs = sys.argv  
argc = len(argvs) 

np.random.seed(0)

def sin(x, T=100):
    return np.sin(2.0 * np.pi * x / T)

def toy_problem(T=277, ampl=0.05):
    x = np.arange(0, T*2)
    #noise = ampl * np.random.uniform(low=-1.0, high=1.0, size=len(x))
    #print(sin(x) + noise)
    #return sin(x) + noise

    f = open(argvs[1])
    line = f.readline()
    
    ncol = 0
    while line:
        #tmp = re.split('\s', line) 
        #x[ncol]=tmp[0]
        x[ncol]=float(line)

        ncol = ncol + 1
        line = f.readline()

    f.close()
    
    return x
        
T = 277
f = gen_data(T)

print(f)

length_of_sequences = T
maxlen = 10

data = []
target = []

for i in range(0, length_of_sequences - maxlen + 1):
    data.append(f[i: i + maxlen])
    target.append(f[i + maxlen])

print(data)
    
X = np.array(data).reshape(len(data), maxlen, 1)
Y = np.array(target).reshape(len(data), 1)

N_train = int(len(data) * 0.9)
N_validation = len(data) - N_train

X_train, X_validation, Y_train, Y_validation = \
    train_test_split(X, Y, test_size=N_validation)

'''
モデル設定
'''
n_in = len(X[0][0])  # 1
n_hidden = 30
n_out = len(Y[0])  # 1


def weight_variable(shape, name=None):
    return np.random.normal(scale=.01, size=shape)


early_stopping = EarlyStopping(monitor='val_loss', patience=10, verbose=1)

model = Sequential()
model.add(SimpleRNN(n_hidden,
                    kernel_initializer=weight_variable,
                    input_shape=(maxlen, n_in)))
model.add(Dense(n_out, kernel_initializer=weight_variable))
model.add(Activation('linear'))

optimizer = Adam(lr=0.001, beta_1=0.9, beta_2=0.999)
model.compile(loss='mean_squared_error',
              optimizer=optimizer)

epochs = 500
batch_size = 30

model.fit(X_train, Y_train,
          batch_size=batch_size,
          epochs=epochs,
          validation_data=(X_validation, Y_validation),
          callbacks=[early_stopping])

truncate = maxlen
Z = X[:1] 

original = [f[i] for i in range(maxlen)]
predicted = [None for i in range(maxlen)]

print(original)

for i in range(length_of_sequences - maxlen + 1):
    z_ = Z[-1:]
    y_ = model.predict(z_)
    sequence_ = np.concatenate(
        (z_.reshape(maxlen, n_in)[1:], y_),
        axis=0).reshape(1, maxlen, n_in)
    Z = np.append(Z, sequence_, axis=0)
    predicted.append(y_.reshape(-1))

plt.rc('font', family='serif')
plt.figure()
plt.ylim([0, 125])
plt.xlim([0, 275])
plt.plot(gen_data(T, ampl=0), linestyle='dotted', color='#aaaaaa')
plt.plot(original, linestyle='dashed', color='black')
plt.plot(predicted, color='black')
plt.show()
