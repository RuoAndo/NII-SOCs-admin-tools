rm -rf pig_*

rm -rf tmp-avg-bytes

hadoop fs -rmr tmp-sf
hadoop fs -rmr tmp-H
hadoop fs -rmr tmp-F_D
hadoop fs -rmr tmp-addrpair
hadoop fs -rmr tmp-avg-bytes

#pig -param SRCS=$1 addrpair-avg.pig
pig -param SRCS=$1 addrpair-avg-1.pig
pig -param SRCS=$1 addrpair-avg-2.pig
pig addrpair-avg-3.pig
pig addrpair-avg-4.pig
pig addrpair-avg-5.pig

hadoop fs -get tmp-avg-bytes

#d=`date +"%Y_%m_%d_%I_%M_%S"`
#mv tmp-addrpair-sid tmp-addrpair-sid-$d
