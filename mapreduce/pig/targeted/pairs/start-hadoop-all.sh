rm -rf /data1/datanode
rm -rf /data1/namenode
rm -rf /tmp/*
mkdir /data1/datanode
mkdir /data1/namenode
hadoop namenode -format
mr-jobhistory-daemon.sh stop historyserver
stop-yarn.sh
stop-dfs.sh
start-dfs.sh 
start-yarn.sh 
mr-jobhistory-daemon.sh start historyserver
hadoop fs -mkdir /user
hadoop fs -mkdir /user/root
