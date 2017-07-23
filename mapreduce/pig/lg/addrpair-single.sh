rm -rf tmp-addrpair
hadoop fs -rmr tmp-addrpair
hadoop fs -rmr $1
hadoop fs -put $1
pig -param SRCS=$1 addrpair.pig
hadoop fs -get tmp-addrpair
#d=`date +"%Y_%m_%d_%I_%M_%S"`
#mv tmp-addrpair tmp-addrpair-$d
