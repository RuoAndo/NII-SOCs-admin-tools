rm -rf pig_*

rm -rf tmp-sid-freq

hadoop fs -rmr tmp-sf
hadoop fs -rmr tmp-H
hadoop fs -rmr tmp-F_D
hadoop fs -rmr tmp-addrpair
hadoop fs -rmr tmp-sid-freq

#pig -param SRCS=$1 addrpair-sid.pig
pig -param SRCS=$1 addrpair-sid-1.pig
pig -param SRCS=$1 addrpair-sid-2.pig
pig addrpair-sid-3.pig
pig addrpair-sid-4.pig
pig addrpair-sid-5.pig

hadoop fs -get tmp-sid-freq

#d=`date +"%Y_%m_%d_%I_%M_%S"`
#mv tmp-addrpair-sid tmp-addrpair-sid-$d
