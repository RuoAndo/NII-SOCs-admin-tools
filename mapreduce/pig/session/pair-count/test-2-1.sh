hadoop fs -rmr tmp-sf
pig -param SRCS=$1 pair-count-2-1.pig
