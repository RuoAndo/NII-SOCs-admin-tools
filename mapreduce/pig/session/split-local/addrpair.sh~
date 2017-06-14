rm -rf addrpair
hadoop fs -rmr addrpair
pig -param SRCS=$1 addrpair.pig
hadoop fs -get addrpair
#d=`date +"%Y_%m_%d_%I_%M_%S"`
#mv tmp-addrpair tmp-addrpair-$d

