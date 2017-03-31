import numpy as np
import pandas as pd
from sklearn.cluster import KMeans
import sys

argvs = sys.argv 

data1 = pd.read_csv(argvs[1])
data2 = pd.read_csv(argvs[2])
data3 = pd.read_csv(argvs[3])

result1 = KMeans(n_clusters=3).fit_predict(data1)
print result1

result2 = KMeans(n_clusters=3).fit_predict(data2)
print result2

result3 = KMeans(n_clusters=3).fit_predict(data3)
print result3

#counter = 0
#for x in result1:
#    print str(x) + ":" + str(counter)
#    counter = counter + 1

counter = 0
for x in result1:
    if x == result2[counter]:
        counter = counter +1
    
print "result1 - result2:" + str(counter)

counter = 0
for x in result1:
    if x == result3[counter]:
        counter = counter +1
    
print "result1 - result3:" + str(counter)

counter = 0
for x in result2:
    if x == result3[counter]:
        counter = counter +1
    
print "result2 - result3:" + str(counter) 

