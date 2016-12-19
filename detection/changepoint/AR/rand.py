#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import numpy as np
import scipy as sp
import statsmodels.tsa.arima_model as ar
import matplotlib.pyplot as plt

from numpy.random import rand, multivariate_normal
data_a = multivariate_normal(rand(1) * 20 - 10, np.eye(1) * (rand()), 250)
data_b = map(float,data_a)
#print data_b

for i in data_b:
    print i

plt.plot(data_b)
plt.show()  
    
