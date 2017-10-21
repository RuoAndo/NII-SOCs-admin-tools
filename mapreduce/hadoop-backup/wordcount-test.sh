echo "a b c a b" > test.txt
hadoop fs -mkdir /user
hadoop fs -mkdir /user/root
hadoop fs -put test.txt 
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.1.jar wordcount test.txt output/
hadoop fs -cat output/part-r-00000
