rm -rf pig_*
hadoop fs -rmr tmp-ad
pig -param SRCS=$1 pair-ranking-3.pig
hadoop fs -get tmp-ad
