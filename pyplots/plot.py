import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from scipy import genfromtxt
import numpy as np
import pandas as pd
import os
import sys

args = sys.argv

d = pd.read_csv(args[1])
#相対パスでは.が現在のパスを明示的に示す方法。 ..で、一つ上の階層を示すなどが使える。

d #データの確認
# データをarray型に
# x = np.array(d["bidirectional"])
x = np.array(d["vertical"])
y = np.array(d["horizontal"])

# グラフ作成
fig = plt.figure()
#ax = Axes3D(fig)
ax = fig.add_subplot(1, 1, 1)

ax.scatter(x, y)
# 軸ラベルの設定
ax.set_xlabel("vertical")
ax.set_ylabel("horizontal")

plt.show()
