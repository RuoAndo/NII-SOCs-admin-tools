import numpy as np
import pandas as pd
from sklearn.cluster import KMeans
import sys

argvs = sys.argv 

data = pd.read_csv(argvs[1])
#print data

result = KMeans(n_clusters=3).fit_predict(data)
print result
