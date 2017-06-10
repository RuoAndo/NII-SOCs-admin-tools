rm -rf pig_*
rm -rf tmp-rfd
hadoop fs -rmr tmp-sf
hadoop fs -rmr tmp-sg
hadoop fs -rmr tmp-ad
hadoop fs -rmr tmp-aj
hadoop fs -rmr tmp-rk
hadoop fs -rmr tmp-rfd
#pig -param SRCS=$1 pair-count-2.pig
pig -param SRCS=$1 pair-count-2-1.pig
pig -param SRCS=$1 pair-count-2-2.pig
pig -param SRCS=$1 pair-count-2-3.pig
pig -param SRCS=$1 pair-count-2-4.pig
pig -param SRCS=$1 pair-count-2-5.pig
pig -param SRCS=$1 pair-count-2-6.pig
hadoop fs -get tmp-rfd
