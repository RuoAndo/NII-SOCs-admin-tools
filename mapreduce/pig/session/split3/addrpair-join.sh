rm -rf addrpair-join
hadoop fs -rmr addrpair-join
pig -param SRCS=$1 addrpair-join.pig
hadoop fs -get addrpair-join
#d=`date +"%Y_%m_%d_%I_%M_%S"`
#mv tmp-addrpair tmp-addrpair-$d
