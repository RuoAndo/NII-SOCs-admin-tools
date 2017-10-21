rpm -ivh jdk-8u66-linux-x64.rpm
echo "export JAVA_HOME=/usr/java/jdk1.8.0_66" >> /root/.bashrc
#bash
source /root/.bashrc
export | grep JAVA
java -version
