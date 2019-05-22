import pandas as pd
import matplotlib.pyplot as plt

import sys
args = sys.argv

df = pd.read_csv(args[1], names=['num1', 'num2'])
df2 = pd.read_csv(args[2], names=['num3', 'num4'])
df3 = pd.read_csv(args[3], names=['num5', 'num6'])

#plt.plot(range(0,10),df['num1'],marker="o")

plt.plot(df['num1'],marker="o")
plt.plot(df2['num3'],marker="o")
plt.plot(df3['num5'],marker="o")

plt.savefig("plot3.png")
plt.show()
