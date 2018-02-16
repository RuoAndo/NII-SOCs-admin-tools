import numpy
import os
import matplotlib.pyplot as plt
from pandas import read_csv
import math
from keras.models import Sequential
from keras.layers import Dense
from keras.layers import LSTM
from sklearn.preprocessing import MinMaxScaler
from sklearn.metrics import mean_squared_error

import sys

argvs = sys.argv
argc = len(argvs)

# convert an array of values into a dataset matrix
def create_dataset(dataset, look_back=1):
	dataX, dataY = [], []
	for i in range(len(dataset)-look_back-1):
		a = dataset[i:(i+look_back), 0]
		dataX.append(a)
		dataY.append(dataset[i + look_back, 0])
	return numpy.array(dataX), numpy.array(dataY)

# fix random seed for reproducibility
numpy.random.seed(7)

# STEP1: reading dataset and split
dataframe = read_csv(argvs[1], usecols=[0], engine='python')
dataset = dataframe.values
dataset = dataset.astype('float32')
dataset_bk = dataset

dataset = dataset / numpy.linalg.norm(dataset) 
scaler = MinMaxScaler(feature_range=(0, 1))
dataset = scaler.fit_transform(dataset)

train_size = int(len(dataset) * 0.95)
test_size = len(dataset) - train_size
train, test = dataset[0:train_size,:], dataset[train_size:len(dataset),:]

# STEP2: reshape into X=t and Y=t+1
look_back = 250
trainX, trainY = create_dataset(train, look_back)
testX, testY = create_dataset(test, look_back)

# STEP3: reshape input to be [samples, time steps, features]
trainX = numpy.reshape(trainX, (trainX.shape[0], 1, trainX.shape[1]))
testX = numpy.reshape(testX, (testX.shape[0], 1, testX.shape[1]))

# STEP4: create and fit the LSTM network
model = Sequential()
model.add(LSTM(2000, input_shape=(1, look_back)))
model.add(Dense(1))
model.compile(loss='mean_squared_error', optimizer='adam')
model.fit(trainX, trainY, epochs=4, batch_size=100, verbose=1)

# STEP5: make predictions
trainPredict = model.predict(trainX)
testPredict = model.predict(testX)

# STEP6: invert predictions
trainPredict = scaler.inverse_transform(trainPredict)
trainY = scaler.inverse_transform([trainY])
testPredict = scaler.inverse_transform(testPredict)
testY = scaler.inverse_transform([testY])

# STEP7: calculate root mean squared error
trainScore = math.sqrt(mean_squared_error(trainY[0], trainPredict[:,0]))
print('Train Score: %.2f RMSE' % (trainScore))
testScore = math.sqrt(mean_squared_error(testY[0], testPredict[:,0]))
print('Test Score: %.2f RMSE' % (testScore))

# STEP8: shift train predictions for plotting
trainPredictPlot = numpy.empty_like(dataset)
trainPredictPlot[:, :] = numpy.nan
trainPredictPlot[look_back:len(trainPredict)+look_back, :] = trainPredict

# STEP9: shift test predictions for plotting
testPredictPlot = numpy.empty_like(dataset)
testPredictPlot[:, :] = numpy.nan
testPredictPlot[len(trainPredict)+(look_back*2)+1:len(dataset)-1, :] = testPredict

# STEP10: plot baseline and predictions
        
ftmp = str(argvs[1]).split("_")

fname = "lstm_" + ftmp[1] + "_" + str(argvs[2])

try:
        os.remove(fname)
except:
        pass

f = open(fname, 'a')

allPlot = []
allPlot2 = []

for x in dataset_bk:
        allPlot.append("0")

counter = 0
for x in trainPredictPlot:
        for y in x:
                if str(y) != "nan":
                        #print(y)
                        allPlot[counter] = str(y)
        counter = counter + 1

counter = 0
for x in testPredictPlot:
        for y in x:
                if allPlot[counter] == 0:
                        allPlot[counter] = y
        counter = counter + 1

counter = 0
for x in allPlot:
        f.write(str(counter) + "," + str(ftmp[1]) + "," + str(x) + "\n")
        counter = counter + 1

print("len:" + str(len(allPlot)))

f.close()

plt.rc('font', family='serif')
plt.figure()

plt.subplot(2, 1, 1)
plt.plot(scaler.inverse_transform(dataset_bk))

plt.subplot(2, 1, 2)
#plt.plot(allPlot2)
plt.plot(trainPredictPlot)
plt.plot(testPredictPlot)

plt.show()

