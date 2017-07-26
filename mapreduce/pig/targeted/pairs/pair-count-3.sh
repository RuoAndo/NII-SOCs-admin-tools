rm -rf tmp-FF
hadoop fs -rmr tmp-FF
pig -param SRCT=$1 pair-count-3.pig
hadoop fs -get tmp-FF
