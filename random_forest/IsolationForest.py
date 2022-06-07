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
    # 正常値のデータを作る
    NORMAL_DATA_N = 1000
    args = {
        # 正常値のデータ点数
        'n_samples': NORMAL_DATA_N,
        # 特徴量の次元数
        'n_features': 2,
        # クラスタの数
        'centers': 1,
        # データを生成するための乱数
        'random_state': 42,
    }
    X_normal, y_normal = make_blobs(**args)

    # 外れ値のデータを作る
    OUTLIER_DATA_N = 200
    DIST_RANGE = 6
    X_outlier = np.random.uniform(low=-DIST_RANGE,
                                  high=DIST_RANGE,
                                  size=(OUTLIER_DATA_N, 2))
    y_outlier = np.ones((OUTLIER_DATA_N, ))

    # 正常値を中心に外れ値を分布させる
    X_outlier += X_normal.mean(axis=0)

    # くっつけて一つのデータセットにする
    X = np.concatenate([X_normal, X_outlier], axis=0)
    y = np.concatenate([y_normal, y_outlier], axis=0)

    # ホールドアウト検証するためにデータを分割する
    X_train, X_test, y_train, y_test = train_test_split(X, y,
                                                        test_size=0.3,
                                                        shuffle=True,
                                                        random_state=42,
                                                        stratify=y)

    # IsolationForest
    #clf = IsolationForest(n_estimators=100,
    #                      contamination='auto',
    #                      behaviour='new',
    #                      random_state=42)

    clf = IsolationForest(n_estimators=100,
                          #contamination='auto',
                          #behaviour='new',
                          random_state=42)

    # 学習用データを学習させる
    clf.fit(X_train)

    # 検証用データを分類する
    y_pred = clf.predict(X_test)

    # IsolationForest は 正常=1 異常=-1 として結果を返す
    y_pred[y_pred == 1] = 0
    y_pred[y_pred == -1] = 1

    # 評価指標を計算する
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
