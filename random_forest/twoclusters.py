#!/usr/bin/env python
# -*- coding: utf-8 -*-

import numpy as np
from scipy import stats
from sklearn.datasets import make_blobs
from sklearn.ensemble import IsolationForest
from sklearn.model_selection import train_test_split
from sklearn.metrics import precision_score
from sklearn.metrics import recall_score
from sklearn.metrics import f1_score
from sklearn.metrics import matthews_corrcoef
from matplotlib import pyplot as plt


def main():
    NORMAL_DATA_N = 1000
    args = {
        'n_samples': NORMAL_DATA_N,
        'n_features': 2,
        # クラスタの数を増やしてみる
        'centers': 2,
        'random_state': 42,
    }
    X_normal, _ = make_blobs(**args)
    y_normal = np.zeros((NORMAL_DATA_N, ))

    OUTLIER_DATA_N = 200
    DIST_RANGE = 6
    X_outlier = np.random.uniform(low=-DIST_RANGE,
                                  high=DIST_RANGE,
                                  size=(OUTLIER_DATA_N, 2))
    y_outlier = np.ones((OUTLIER_DATA_N, ))

    X_outlier += X_normal.mean(axis=0)

    X = np.concatenate([X_normal, X_outlier], axis=0)
    y = np.concatenate([y_normal, y_outlier], axis=0)

    X_train, X_test, y_train, y_test = train_test_split(X, y,
                                                        test_size=0.3,
                                                        shuffle=True,
                                                        random_state=42,
                                                        stratify=y)

    #clf = IsolationForest(n_estimators=100,
    #                      contamination='auto',
    #                      behaviour='new',
    #                      random_state=42)

    clf = IsolationForest(n_estimators=100,
    #                      contamination='auto',
    #                      behaviour='new',
                          random_state=42)

    clf.fit(X_train)

    y_pred = clf.predict(X_test)

    y_pred[y_pred == 1] = 0
    y_pred[y_pred == -1] = 1

    print('precision:', precision_score(y_test, y_pred))
    print('recall:', recall_score(y_test, y_pred))
    print('f1:', f1_score(y_test, y_pred))
    print('mcc:', matthews_corrcoef(y_test, y_pred))

    xx, yy = np.meshgrid(np.linspace(X_normal[:, 0].mean() - DIST_RANGE * 1.2,
                                     X_normal[:, 0].mean() + DIST_RANGE * 1.2,
                                     100),
                         np.linspace(X_normal[:, 1].mean() - DIST_RANGE * 1.2,
                                     X_normal[:, 1].mean() + DIST_RANGE * 1.2,
                                     100))
    Z = clf.decision_function(np.c_[xx.ravel(), yy.ravel()])
    Z = Z.reshape(xx.shape)

    plt.contourf(xx, yy, Z, cmap=plt.cm.Blues_r)
    threshold = stats.scoreatpercentile(y_pred,
                                        100 * (OUTLIER_DATA_N / NORMAL_DATA_N))
    plt.contour(xx, yy, Z, levels=[threshold],
                    linewidths=2, colors='red')

    plt.scatter(X_train[y_train == 0, 0],
                X_train[y_train == 0, 1],
                label='train negative',
                c='b')
    plt.scatter(X_train[y_train == 1, 0],
                X_train[y_train == 1, 1],
                label='train positive',
                c='r')

    plt.scatter(X_test[y_pred == 0, 0],
                X_test[y_pred == 0, 1],
                label='test negative (prediction)',
                c='g')
    plt.scatter(X_test[y_pred == 1, 0],
                X_test[y_pred == 1, 1],
                label='test positive (prediction)',
                c='y')

    plt.legend()
    plt.show()


if __name__ == '__main__':
    main()

