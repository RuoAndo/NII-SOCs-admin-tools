rm -rf pig_*
rm -rf tmp-ad
hadoop fs -rmr tmp-ad
hadoop fs -rmr tmp-ap
pig -param SRCS=$1 pair-ranking-3.pig
hadoop fs -get tmp-ad
