# coding: utf-8
from math import log, ceil
import numpy as np
from scipy.stats import norm, t
import matplotlib.pyplot as plt
import KF
import pdb; pdb.set_trace()

class KFAnomalyDetection:
    datalist = []
    outlier_score_list = []
    change_score_list = []

    outlier_score_smooth = []
    change_score_smooth = []

    outlier_resid = None
    change_resid = None
    outlier_pred = None
    change_pred = None

    def __init__(self, term, smooth, k=2, p=0, q=0, w=10):
        self.kf_outlier_score = KF.KalmanFiltering(k,p,q,term=term, w=w)
        self.kf_first_smooth_score = KF.KalmanFiltering(k,p,q,term=smooth, w=w)
        self.kf_change_score = KF.KalmanFiltering(k,p,q,term=term, w=w)
        self.kf_second_smooth_score = KF.KalmanFiltering(k,p,q,term=smooth, w=w)
        self.term = term

    def forward_step(self, new_data):
        # add new_data to datalist
        if len(self.datalist)>=self.term:
            self.datalist.pop(0)
            self.datalist.append(new_data)
        else:
            self.datalist.append(new_data)

        # compute score
        if self.outlier_pred is None:
            self.first_step(new_data)
        else:
            self.calculate_score_step(new_data)
            self.learn_step(new_data)

    def conversion_score(self, train, var):
        """convert score to log loss"""
        m = np.mean(train)
        s = np.std(train)
        try:
            if s < 1: s=1
            px = norm.pdf(var, m, s) if norm.pdf(var, m, s)!=0.0 else 1e-308
            res = -log(px)
            return res
        except:
            return 0

    def first_step(self, new_data):
        # learn outlier model
        self.outlier_resid, self.outlier_pred = \
                self.learn_KF(self.kf_outlier_score, new_data)
        # calculate outlier score
        self.calculate_score(self.kf_first_smooth_score, self.outlier_resid,
                    self.outlier_pred, new_data, self.outlier_score_list,
                    self.outlier_score_smooth)
        # learn cnage model
        self.change_resid, self.change_pred = \
                self.learn_KF(self.kf_change_score, self.outlier_score_smooth[-1])
        # calculate change score
        self.calculate_score(self.kf_second_smooth_score, self.change_resid,
                    self.change_pred, self.outlier_score_smooth[-1],
                    self.change_score_list, self.change_score_smooth)

    def learn_step(self, data):
        self.outlier_resid, self.outlier_pred = \
                self.learn_KF(self.kf_outlier_score, data)
        self.change_resid, self.change_pred = \
                self.learn_KF(self.kf_change_score, self.outlier_score_smooth[-1])

    def learn_KF(self, func, data):
        """leaning KF from new data"""
        pred = func.forward_backward(data)
        resid = np.abs( func.XSS[:func.term,0] - np.array(self.datalist) ) # residuals
        return resid, pred

    def calculate_score_step(self, new_data):
        # calculate outlier score
        self.calculate_score(self.kf_first_smooth_score, self.outlier_resid,
                    self.outlier_pred, new_data, self.outlier_score_list,
                    self.outlier_score_smooth)
        # calculate change score
        self.calculate_score(self.kf_second_smooth_score, self.change_resid,
                    self.change_pred, self.outlier_score_smooth[-1],
                    self.change_score_list, self.change_score_smooth)

    def calculate_score(self, func, resid, pred, new_data, storage_score_list, storage_smooth_list):
        score = self.conversion_score( resid, abs(float(pred) - float(new_data)) )
        #print 'got score', score
        storage_score_list.append(score)
        #print 'smoothing score'
        storage_smooth_list.append( func.forward_backward(score, smoothing=1) )

if __name__=='__main__':
    fname = 'test'
    term = 3 # time window of training
    smooth = 1
    kfad = KFAnomalyDetection(term,smooth,2,0,0,20)
    datalist = []
    of = open('score_out.txt','w')    
    dlist = np.hstack( (np.random.normal(0,1,100),np.random.normal(10,0.2,20),np.random.normal(0,1,100)) )
    for data in dlist:
        kfad.forward_step(data)
        of.write( str(kfad.change_score_smooth[-1])+'\n' )
    of.close()

    rng = range( len(dlist.tolist()) )
    #plt.plot(rng,dlist,label=u"data")
    #plt.show()
    #plt.plot(rng,kfad.change_score_smooth,label=u"score")
    #plt.show()

