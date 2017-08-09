echo $1
python trim.py $1 > $1.trim
hadoop fs -rmr $1.trim
hadoop fs -put $1.trim
./addrpair.sh $1.trim
./addrpair-join.sh $1.trim
./addrpair-sid.sh $1.trim
./addrpair-avg.sh $1.trim
./join.sh $1.trim

