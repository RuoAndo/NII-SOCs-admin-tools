rm -rf /root/datanode
rm -rf /root/namenode
rm -rf /tmp/*
mkdir /root/datanode
mkdir /root/namenode
hadoop namenode -format
#mr-jobhistory-daemon.sh stop historyserver
#stop-yarn.sh
#stop-dfs.sh
start-dfs.sh 
start-yarn.sh 
mr-jobhistory-daemon.sh start historyserver
hadoop fs -mkdir /user
hadoop fs -mkdir /user/root

