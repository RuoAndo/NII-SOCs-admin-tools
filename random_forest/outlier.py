from sklearn.datasets import load_iris
from sklearn.ensemble import RandomForestClassifier
import numpy as np
import matplotlib.pyplot as plt

def proximity(data):
  n_samples = np.zeros((len(data),len(data)))
  n_estimators = len(data[0])
  for e,est in enumerate(np.transpose(np.array(data))):
    for n,n_node in enumerate(est):
      for k,k_node in enumerate(est):
        if n_node == k_node:
          n_samples[n][k] += 1
  n_samples = 1.0 * np.array(n_samples) / n_estimators
  return n_samples

def outlier(data, label):
  N = len(label)
  pbar = [0] * N
  data = np.square(data)

  # クラス内の近似度の平均値を求める
  for n,n_prox2 in enumerate(data):
    for k,k_prox2 in enumerate(n_prox2):
      if label[n] == label[k]:
        pbar[n] += k_prox2
    if pbar[n] == 0.0:
      pbar[n] = 1.0e-32

  # 外れ値を求める
  out = N / np.array(pbar)

  # 各クラスの外れ値の中央値を求める
  meds = {}
  for n,l in enumerate(label):
    if l not in meds.keys():
      meds[l] = []
    meds[l].append(out[n])

  label_uniq = list(set(label))
  med_uniq = {} # 実際の各クラスの中央値はこの変数に入る 
  for l in label_uniq:
    med_uniq[l] = np.median(meds[l])

  # 各クラスの外れ値の中央絶対偏差(MAD)を求める
  mads = {}
  for n,l in enumerate(label):
    if l not in mads.keys():
      mads[l] = []
    mads[l].append(np.abs(out[n] - med_uniq[l]))

  mad_uniq = {} # 実際の各クラスのMADはこの変数に入る
  for l in label_uniq:
    mad_uniq[l] = np.median(mads[l])

  # 各データの外れ値を中央値，MADで正規化する
  outlier = [0] * N
  for n,l in enumerate(label):
    if mad_uniq[l] == 0.0:
      outlier[n] = out[n] - med_uniq[l]
    else:
      outlier[n] = (out[n] - med_uniq[l]) / mad_uniq[l]

  return outlier


if __name__ == '__main__':
  iris = load_iris()
  X = iris.data
  y = iris.target
  div = 50
  best_oob = len(y)

  for i in range(20):
    rf = RandomForestClassifier(max_depth=5,n_estimators=10,oob_score=True)
    rf.fit(X, y)
    if best_oob > rf.oob_score:
      app = rf.apply(X)

  prx = proximity(app)
  out = outlier(prx,y)

  fig = plt.figure(figsize=[7,4])
  ax = fig.add_subplot(1,1,1)

  ax.scatter(np.arange(div),out[:div], c="r",marker='o', label='class 0')
  ax.scatter(np.arange(div,div*2),out[div:div*2], c="b",marker='^', label='class 1')
  ax.scatter(np.arange(div*2,div*3),out[div*2:], c="g",marker='s', label='class 2')

  ax.set_ylabel('outlier') 
  ax.legend(loc="best")
  fig.savefig("out.png")

