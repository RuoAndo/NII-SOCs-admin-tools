#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import numpy as np
import scipy as sp
import statsmodels.tsa.arima_model as ar
import matplotlib.pyplot as plt 

# Change Finder
class change_finder(object):

    #def __init__(self, term=70, window=5, order=(1, 1, 0)):
    def __init__(self, term=70, window=5, order=(1, 1, 0)):
        self.term = term
        self.window = window
        # ARIMA order
        self.order = order
        #print("term:", term, "window:", window, "order:", order)

    # takes X, returns score vector
    def main(self, X):
        req_length = self.term * 2 + self.window + np.round(self.window / 2) - 2
        if len(X) < req_length:
            sys.exit("err: Data length is not enough.")

        print "Scoring start."
        # X = (X - np.mean(X, axis=0)) / np.std(X, axis=0)

        print "outlier detection."
        score = self.outlier(X)
        
        print "changepoint detecion"
        score = self.changepoint(score)

        space = np.zeros(len(X) - len(score))
        score = np.r_[space, score]
        
        #print score
        print("Done.")
        return score

    # Outlier Score <-  Data
    def outlier(self, X):
        count = len(X) - self.term - 1

        # train
        trains = [X[t:(t + self.term)] for t in range(count)]
        target = [X[t + self.term + 1] for t in range(count)]
        fit = [ar.ARIMA(trains[t], self.order).fit(disp=0) for t in range(count)]

        # predict
        resid = [fit[t].forecast(1)[0][0] - target[t] for t in range(count)]
        pred = [fit[t].predict() for t in range(count)]
        m = np.mean(pred, axis=1)
        s = np.std(pred, axis=1)

        # logloss
        score = -sp.stats.norm.logpdf(resid, m, s)

        # heikatuka
        score = self.heikatuka(score, self.window)

        print "outlier detection done."
        # print score
        return score

    # ChangepointScore <- OutlierScore
    def changepoint(self, X):
        count = len(X) - self.term - 1

        trains = [X[t:(t + self.term)] for t in range(count)]
        target = [X[t + self.term + 1] for t in range(count)]
        m = np.mean(trains, axis=1)
        s = np.std(trains, axis=1)

        score = -sp.stats.norm.logpdf(target, m, s)
        score = self.heikatuka(score, np.round(self.window / 2))

        print "changepoint detection done."

        for i in score[0:250]:
            print float(i)

        plt.plot(score)
        plt.show()

        #std = np.std(score)

        nm = score/np.linalg.norm(score)

        plt.plot(nm)
        plt.show()
        
        return score

    # changepointScore <- outlierScore
    # w: Window size
    def heikatuka(self, X, w):
        return np.convolve(X, np.ones(w) / w, 'valid')


def example():
    from numpy.random import rand, multivariate_normal
    data_a = multivariate_normal(rand(1) * 20 - 10, np.eye(1) * (rand()), 250)
    data_b = multivariate_normal(rand(1) * 20 - 10, np.eye(1) * (rand()), 250)
    data_c = multivariate_normal(rand(1) * 20 - 10, np.eye(1) * (rand()), 250)
    data_d = multivariate_normal(rand(1) * 20 - 10, np.eye(1) * (rand()), 250)

    for i in data_a:
        print float(i)

    plt.plot(data_a)
    plt.show()    
        
    X = np.r_[data_a, data_b, data_c, data_d][:, 0]
    #X = np.r_[data_a][:, 0]
    #c_cf = change_finder(term=70, window=5, order=(2, 2, 0))
    c_cf = change_finder(term=70, window=5, order=(2, 2, 0))
    result = c_cf.main(X)
    return result

if __name__ == '__main__':
    #print(example())
    example()
