#wget http://ftp.kddilabs.jp/infosystems/apache//commons/math/binaries/commons-math3-3.6.1-bin.tar.gz
#tar zxvf commons-math3-3.6.1-bin.tar.gz
#wget https://github.com/google/guava/releases/download/v20.0/guava-20.0.jar
javac -cp ./guava-20.0.jar:./commons-math3-3.6.1/commons-math3-3.6.1.jar ChangeFinder.java
java -cp ./guava-20.0.jar:./commons-math3-3.6.1/commons-math3-3.6.1.jar:. ChangeFinder $1
