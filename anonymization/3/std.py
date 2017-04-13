import numpy as np
import matplotlib.pyplot as plt
#matplotlib inline
import matplotlib.font_manager
from scipy import stats

Y = np.loadtxt("tmp",delimiter=",",dtype=float)

# 1: session ID
# 2: time
# 3: dest
# 4: src
# 5: dest
# 6: src
# 7: bts

dstIP = Y[:,3]
dstIP_copy = np.copy(dstIP)
dstIP_std = (dstIP_copy - dstIP_copy.mean()) / dstIP_copy.std()
Y[:,3] = dstIP_std

srcIP = Y[:,4]
srcIP_copy = np.copy(srcIP)
srcIP_std = (srcIP_copy - srcIP_copy.mean()) / srcIP_copy.std()
Y[:,4] = srcIP_std

srcport = Y[:,5]
srcport_copy = np.copy(srcport)
srcport_std = (srcport_copy - srcport_copy.mean()) / srcport_copy.std()
Y[:,5] = srcport_std

dstport = Y[:,6]
dstport_copy = np.copy(dstport)
dstport_std = (dstport_copy - dstport_copy.mean()) / dstport_copy.std()
Y[:,6] = dstport_std

#print Y.tolist()

for x in Y.tolist():
    x_str = map(str,x)
    # print x_str
    print ",".join(x_str) 
