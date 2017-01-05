#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import numpy as np
import scipy as sp

def generate():
    from numpy.random import rand, multivariate_normal
    data_a = multivariate_normal(rand(1) * 20 - 10, np.eye(1) * (rand()), 250)
    data_b = multivariate_normal(rand(1) * 20 - 10, np.eye(1) * (rand()), 250)
    data_c = multivariate_normal(rand(1) * 20 - 10, np.eye(1) * (rand()), 250)
    data_d = multivariate_normal(rand(1) * 20 - 10, np.eye(1) * (rand()), 250)

    str_a = map(float,data_a)
    for i in str_a:
        print i

    str_b = map(float,data_b)
    for i in str_b:
        print i

    str_c = map(float,data_c)
    for i in str_c:
        print i

    str_d = map(float,data_d)
    for i in str_d:
        print i
    
    #print data_b
    #print data_c
    #print data_d

if __name__ == '__main__':
    #print(example())
    generate()
