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

#data =  np.ones((288, 95))
#target =  np.ones((288, 95))

data =  []
target =  []
maxlen = 95

f = open(argvs[1])

line = f.readline() 

nrow = 0
while line:
    tmp = re.split('\s', line) 
    #tmp = line.split("\s")
    #print(tmp)
    #print(len(tmp))
    
    ncol = 0
    b = np.arange(95)
    for i in tmp:
        #print(str(i) + ":" + str(ncol))
        #print(str(ncol) + ":" + str(nrow))
        if str(i) !="":
            #a[nrow,ncol] = int(str(i).strip())
            b[ncol] = int(str(i).strip())

        ncol = ncol + 1

    #print(b)
        
    #data = np.append(data,np.array([b]),axis=0)
    #target = np.append(data,np.array([b]),axis=0)
    data.append(np.array(b))
    target.append(np.array(b[-1]))
    #a.append(b)
        
    nrow = nrow + 1
    line = f.readline()

ff = data
print(len(data))
#print(data)

X = np.array(data).reshape(len(data), maxlen, 1)
Y = np.array(target).reshape(len(data),1)

N_train = int(len(data) * 0.9)
N_validation = len(data) - N_train

X_train, X_validation, Y_train, Y_validation = \
    train_test_split(X, Y, test_size=N_validation)

n_in = len(X[0][0])
n_hidden = 20
n_out = len(Y[0])

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
batch_size = 10

model.fit(X_train, Y_train,
          batch_size=batch_size,
          epochs=epochs,
          validation_data=(X_validation, Y_validation),
          callbacks=[early_stopping])

truncate = maxlen
Z = X[:1]  # 元データの最初の一部だけ切り出し

length_of_sequences = 2 * 95

original = [ff[i] for i in range(maxlen)]
predicted = [None for i in range(maxlen)]

for i in range(length_of_sequences - maxlen + 1):
    z_ = Z[-1:]
    y_ = model.predict(z_)
    sequence_ = np.concatenate(
        (z_.reshape(maxlen, n_in)[1:], y_),
        axis=0).reshape(1, maxlen, n_in)
    Z = np.append(Z, sequence_, axis=0)
    predicted.append(y_.reshape(-1))

#print(original)

o = []
for j in original:
    o.append(j)

p = []
for j in predicted:
    if j == None:
        p.append(0)
    else:
        p.append(float(j))
        
print(len(o))
print(o)

print(len(p))
print(p)
        
#plt.rc('font', family='serif')
#plt.figure()
#plt.ylim([-1.5, 1.5])
#plt.plot(toy_problem(T, ampl=0), linestyle='dotted', color='#aaaaaa')
#plt.plot(original, linestyle='dashed', color='black')
#plt.plot(predicted, color='black')
#plt.show()
