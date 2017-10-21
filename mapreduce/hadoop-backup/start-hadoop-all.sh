rm -rf /sql_data1/datanode
rm -rf /sql_data1/namenode
rm -rf /tmp/*
mkdir /sql_data1/datanode
mkdir /sql_data1/namenode
hadoop namenode -format
mr-jobhistory-daemon.sh stop historyserver
stop-yarn.sh
stop-dfs.sh
start-dfs.sh 
start-yarn.sh 
mr-jobhistory-daemon.sh start historyserver
hadoop fs -mkdir /user
hadoop fs -mkdir /user/root

