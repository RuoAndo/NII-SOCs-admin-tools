rm -rf pig_*

rm -rf tmp-sid

hadoop fs -rmr tmp-pair
hadoop fs -rmr tmp-sid

pig -param SRCS=$1 sid.pig
#pig -param SRCS=$1 avg-1.pig
#pig avg-2.pig

hadoop fs -get tmp-sid

#d=`date +"%Y_%m_%d_%I_%M_%S"`
#mv tmp-addrpair-sid tmp-addrpair-sid-$d
