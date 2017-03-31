import numpy as np
import matplotlib.pyplot as plt
#matplotlib inline
import matplotlib.font_manager
from scipy import stats

Y = np.loadtxt("tmp",delimiter=",",dtype=float)
dstIP = Y[:,2]
#print dstIP
#print Y

#print "---- Y[:,2] std ----"

dstIP_copy = np.copy(dstIP)

dstIP_std = (dstIP_copy - dstIP_copy.mean()) / dstIP_copy.std()

#print dstIP_std
Y[:,2] = dstIP_std

#print Y.tolist()

for x in Y.tolist():
    x_str = map(str,x)
    # print x_str
    print ",".join(x_str) 
