# Towards Changepoint detection

reqiurements:

Apache Commons Math 3.6.1 http://commons.apache.org/proper/commons-math/download_math.cgi
Google Guava https://github.com/google/guava/releases

<pre>
wget http://ftp.kddilabs.jp/infosystems/apache//commons/math/binaries/commons-math3-3.6.1-bin.tar.gz
tar zxvf commons-math3-3.6.1-bin.tar.gz
wget https://github.com/google/guava/releases/download/v20.0/guava-20.0.jar
javac -cp ./guava-20.0.jar:./commons-math3-3.6.1/commons-math3-3.6.1.jar AutoCorrelationTime.java
java -cp ./guava-20.0.jar:./commons-math3-3.6.1/commons-math3-3.6.1.jar:. AutoCorrelationTime

[1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
[120.0, 64.0, 18.0, -17.0, -40.0, -50.0, -46.0, -27.0, 8.0, 60.0, 40.0, 21.0, 4.0, -10.0, -20.0, -25.0, -24.0, -16.0]
[1.0, 0.5037037037037035, 0.1416666666666666, -0.13379629629629625]
8.897025171624716
</pre>

