#coding:utf-8
# K-means

import numpy as np
import sys
#from pylab import *

argvs = sys.argv

K = 2  # the number of clusters (given)

def scale(X):
    """ normalizing X """
    # col: property
    col = X.shape[1]
    
    # mean and str for each property
    mu = np.mean(X, axis=0)
    sigma = np.std(X, axis=0)
    
    # std for property
    for i in range(col):
        X[:,i] = (X[:,i] - mu[i]) / sigma[i]
    
    return X

def J(X, mean, r):
    """ evaluation function for minimizing distance """
    sum = 0.0
    for n in range(len(X)):
        temp = 0.0
        for k in range(K):
            temp += r[n, k] * np.linalg.norm(X[n] - mean[k]) ** 2
        sum += temp
    return sum

if __name__ == "__main__":
    data = np.genfromtxt(argvs[1])
    X = data[:, 0:2]
    X = scale(X)
    N = len(X)
    
    # initialize
    mean = np.random.rand(K, 2)
    
    # r is the assignment of clusters
    r = np.zeros( (N, K) )
    r[:, 0] = 1

    # init 
    target = J(X, mean, r)
    
    turn = 0
    while True:
        print turn, target
        
        # Step 1 : calculating cluster assignment with current mean(s)
        for n in range(N):
            idx = -1
            min = sys.maxint
            for k in range(K):
                temp = np.linalg.norm(X[n] - mean[k]) ** 2
                if temp < min:
                    idx = k
                    min = temp
            for k in range(K):
                r[n, k] = 1 if k == idx else 0
        
        # Step 2 : updating mean with current cluster assignment
        for k in range(K):
            numerator = 0.0
            denominator = 0.0
            for n in range(N):
                numerator += r[n, k] * X[n]
                denominator += r[n, k]
            mean[k] = numerator / denominator
        
        # convergence
        new_target = J(X, mean, r)
        diff = target - new_target
        if diff < 0.01:
            break
        target = new_target
        turn += 1

    #print mean
    #print r

print "----"
for i in range(K):
    print "cluster:" + str(i) + ":" + str(mean[i])
print "----"
for n in range(N):
    print "data:" + str(n) + ":" + str(X[n]) + str(r[n])
                
