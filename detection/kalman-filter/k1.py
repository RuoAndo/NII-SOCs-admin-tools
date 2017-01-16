#!/usr/bin/env python
# -*- coding: utf-8 -*-

import numpy as np
import matplotlib.pyplot as plt

def lkf(T, Y, U, mu0, Sigma0, A, B, C, Q, R):

    mu = mu0 
    Sigma = Sigma0 

    M = [mu] 

    for i in range(T):
        # estimate
        mu_ = A * mu + B * U[i]
        Sigma_ = Q + A * Sigma * A.T

        # update
        yi = Y[i+1] - C * mu_
        S = C * Sigma_ * C.T + R
        K = Sigma_ * C.T * S.I
        mu = mu_ + K * yi
        Sigma = Sigma_ - K * C * Sigma_
        M.append(mu)

    return M

def main():
    A = np.mat([[1,0], [0,1]])
    B = np.mat([[1,0], [0,1]])
    Q = np.mat([[1,0], [0,1]])

    C = np.mat([[1,0], [0,1]])
    R = np.mat([[2,0], [0,2]])

    T = 10 
    x = np.mat([[0],[0]]) 
    
    X = [x]
    Y = [x]

    u = np.mat([[2],[2]])
    U = [u]
    for i in range(T):
        X = A * x + B * u + np.random.multivariate_normal([0, 0], Q, 1).T
        X =+ x
        y = C * x + np.random.multivariate_normal([0, 0], R, 1).T
        Y.append(y)
        U.append(u)

    # LKF
    mu0 = np.mat([[0],[0]])
    Sigma0 = np.mat([[0,0],[0,0]])
    M = lkf(T, Y, U, mu0, Sigma0, A, B, C, Q, R)

    st = np.array( [] )
    G = list(Y)
    for i in G:
        G1 = map(float, i)
        st = np.append(st, G1[0])
        st = np.append(st,G1[1])
    
    ob = np.array( [] )
    F = list(M)
    for i in F:
        F1 = map(float, i)
        ob = np.append(ob, F1[0])
        ob = np.append(ob, F1[1])

    plt.plot(np.array(ob),'rs-')
    plt.plot(np.array(st),'bo-')
    plt.show()
    
if __name__ == '__main__':
    main()
