hadoop fs -rmr tmp-addrpair
hadoop fs -rmr tmp-addrpair-avg
pig -param SRCS=$1 addrpair-avg-1.pig
pig -param SRCS=$1 addrpair-avg-2.pig
hadoop fs -get tmp-addrpair-avg
d=`date +"%Y_%m_%d_%I_%M_%S"`
mv tmp-addrpair-avg tmp-addrpair-avg-$d
