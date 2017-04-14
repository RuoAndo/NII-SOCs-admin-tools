import numpy as np
import pandas as pd
from sklearn.cluster import KMeans
import sys

argvs = sys.argv 

data = pd.read_csv(argvs[1])
#print data

result = KMeans(n_clusters=3).fit_predict(data)

print result
counter0 = 0
counter1 = 0
counter2 = 0

comstr = ""
for x in result:
    comstr = comstr + "," + str(x).strip()

    if str(x) == "0":
        counter0 = counter0 + 1
    
    if str(x) == "1":
        counter1 = counter1 + 1
        
    if str(x) == "2":
        counter2 = counter2 + 1
    
#print comstr
print "counter0: " + str(counter0)
print "counter1: " + str(counter1)
print "counter2: " + str(counter2)
