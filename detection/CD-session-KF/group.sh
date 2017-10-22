hadoop fs -rmr $1
hadoop fs -rmr dump-$1
hadoop fs -put $1
pig -param SC=$1 group.pig
rm -rf dump-$1
hadoop fs -get dump-$1
