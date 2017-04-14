import numpy as np
import matplotlib.pyplot as plt
#matplotlib inline
import matplotlib.font_manager
from scipy import stats

Y = np.loadtxt("tmp",delimiter=",",dtype=float)

#print Y

# 0: session ID
# 1: time
# 2: id
# 3: id
# 10: icmp
# 14: priority

SID = Y[:,0]
SID_copy = np.copy(SID)
SID_std = (SID_copy - SID_copy.mean()) / SID_copy.std()
Y[:,0] = SID_std

ID1 = Y[:,1]
ID1_copy = np.copy(ID1)
ID1_std = (ID1_copy - ID1_copy.mean()) / ID1_copy.std()
Y[:,1] = ID1_std

ID2 = Y[:,2]
ID2_copy = np.copy(ID2)
ID2_std = (ID2_copy - ID2_copy.mean()) / ID2_copy.std()
Y[:,2] = ID2_std

ICMP = Y[:,3]
ICMP_copy = np.copy(ICMP)
ICMP_std = (ICMP_copy - ICMP_copy.mean()) / ICMP_copy.std()
Y[:,3] = ICMP_std

PRI = Y[:,4]
PRI_copy = np.copy(PRI)
PRI_std = (PRI_copy - PRI_copy.mean()) / PRI_copy.std()
Y[:,4] = PRI_std
        
for x in Y.tolist():
    x_str = map(str,x)
    # print x_str
    print ",".join(x_str) 
