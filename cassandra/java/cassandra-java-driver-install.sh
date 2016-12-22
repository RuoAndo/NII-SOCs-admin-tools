wget http://ftp.riken.jp/net/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
tar zxvf apache-maven-3.3.9-bin.tar.gz 
git clone https://github.com/mycila/license-maven-plugin.git
cd license-maven-plugin
/root/apache-maven-3.3.9/bin/mvn package
/root/apache-maven-3.3.9/bin/mvn clean install
git clone https://github.com/datastax/java-driver.git
cd java-driver/
/root/apache-maven-3.3.9/bin/mvn package
yum install mlocate -y 
updatedb
#/root/.m2/repository/com/datastax/cassandra/cassandra-driver-core/3.0.3/cassandra-driver-core-3.0.3.jar
