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

argvs = sys.argv  
argc = len(argvs) 

length_of_sequences = 288
maxlen = 48

f = np.arange(0, 288)
f2 = open(argvs[1])
line = f2.readline() 

counter = 0
while line:
    f[counter] = float(line.strip())
    counter = counter + 1
    line = f2.readline()

f2.close()

data = []
target = []

for i in range(0, length_of_sequences - maxlen):
    data.append(f[i: i + maxlen])
    target.append(f[i + maxlen])

print(target)

X = np.array(data).reshape(len(data), maxlen, 1)
Y = np.array(target).reshape(len(data), 1)

N_train = int(len(data) * 0.90)
N_validation = len(data) - N_train

X_train, X_validation, Y_train, Y_validation = \
    train_test_split(X, Y, test_size=N_validation)

n_in = len(X[0][0])  # 1
n_hidden = 40
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

epochs = 250
batch_size = 10

model.fit(X_train, Y_train,
          batch_size=batch_size,
          epochs=epochs,
          validation_data=(X_validation, Y_validation),
          callbacks=[early_stopping])

truncate = maxlen
Z = X[:1] 

original = [f[i] for i in range(maxlen)]
predicted = [None for i in range(maxlen)]

for i in range(length_of_sequences - maxlen + 1):
    z_ = Z[-1:]
    y_ = model.predict(z_)
    sequence_ = np.concatenate(
        (z_.reshape(maxlen, n_in)[1:], y_),
        axis=0).reshape(1, maxlen, n_in)
    Z = np.append(Z, sequence_, axis=0)
    predicted.append(y_.reshape(-1))
    
f = open('tmpout', 'a') 

predicted_array = []

for j in predicted:
    if "None" not in str(j):
        f.writelines(str(j).replace("[","").replace("]","") + "\n")
        predicted_array.append(float(str(j).replace("[","").replace("]","")))
f.close()

print "MAX:" + str(max(predicted_array)) 
print "T:" + str(predicted_array.index(max(predicted_array)))

plt.rc('font', family='serif')
plt.figure()

plt.plot(predicted, color='black')
plt.show()

