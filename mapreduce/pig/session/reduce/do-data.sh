echo $1
hadoop fs -rmr $1
hadoop fs -put $1
./addrpair.sh $1
./addrpair-join.sh $1
./addrpair-sid.sh $1
./addrpair-avg.sh $1
./join.sh $1

