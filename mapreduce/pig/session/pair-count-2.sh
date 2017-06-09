hadoop fs -rmr tmp-sf
hadoop fs -rmr tmp-sg
hadoop fs -rmr tmp-ad
hadoop fs -rmr tmp-aj
hadoop fs -rmr tmp-rk
pig -param SRCS=$1 pair-count-2.pig

