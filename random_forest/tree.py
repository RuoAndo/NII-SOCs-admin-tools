import numpy as np
import matplotlib.pyplot as plt
from sklearn import tree
import time
start = time.time()

# データ読み込み、初期値セット、前処理
data = np.loadtxt('tree.csv', delimiter=',', skiprows=1)   # 学習データ読み込み
XY   = data[:,0:2]                                         # X,Y値
L    = data[:,2].astype(np.int)                            # ラベル値
A    = max(data[:,0]).astype(np.int)                       # Xの最大値 
B    = max(data[:,1]).astype(np.int)                       # Yの最大値
C,D  = np.meshgrid(np.arange(A),np.arange(B))               
E    = np.hstack((C.reshape(A*B,1), D.reshape(A*B,1)))     # X,Yの組み合わせ 

# 分類テスト
clf = tree.DecisionTreeClassifier()                        # Decision tree
clf.fit(XY, L)                                             # 分類実行
est = clf.predict(E)                                       # 分類結果

print("time:" , time.time() - start)

# グラフ描画
plt.pcolormesh(C, D, est.reshape(C.shape), alpha=0.05)     # 境界線をプロット
plt.plot(XY[L == 1, 0],XY[L == 1, 1],'^')                  # 基データ(ラベル1)
plt.plot(XY[L == 0, 0],XY[L == 0, 1],'o')                  # 基データ(ラベル0)
plt.grid(True)
plt.show()

