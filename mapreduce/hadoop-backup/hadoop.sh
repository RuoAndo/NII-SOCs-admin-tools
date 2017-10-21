tar -xzvf hadoop-2.7.1.tar.gz 
mv hadoop-2.7.1 /usr/
echo "export HADOOP_HOME=/usr/hadoop-2.7.1" >> /root/.bashrc
echo "export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$JAVA_HOME/bin:$PATH" >> /root/.bashrc
source /root/.bashrc
hadoop version
