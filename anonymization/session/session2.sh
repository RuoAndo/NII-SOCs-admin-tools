rm -rf tmp-s
hadoop fs -rmr tmp-s
pig -param SRCS=$1 -param LOGDATE=`date +"%Y_%m_%d_%I_%M_%S"` session2.pig
hadoop fs -get tmp-s
