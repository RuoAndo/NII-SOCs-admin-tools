from pandas import read_csv
from matplotlib import pyplot
import sys

argvs = sys.argv
series = read_csv(argvs[1], header=0, index_col=0)

#pyplot.xticks(rotation=70)
series.plot()
pyplot.show()

