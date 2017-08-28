hadoop fs -rmr $1                                                                                                       
hadoop fs -put $1                                                                                                       
hadoop fs -rmr $1-labeled
pig -param SRCS=$1 label.pig    
