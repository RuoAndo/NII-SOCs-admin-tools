rm -rf pig_*
hadoop fs -rmr stmp
hadoop fs -rmr ptmp
pig -param SRCS=$1 pair-ranking-2.pig
