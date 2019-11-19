import matplotlib.pyplot as plt #描画ライブラリ
import pandas_datareader.data as web #データのダウンロードライブラリ
tsd = web.DataReader("usmv","yahoo","1980/1/1").dropna()#jpy
tsd.loc[:,'Adj Close'].plot()

