if [ ! -e piggybank.jar ]; then
echo "no piggybank.jar"
exit 1
fi

cp /data1/piggybank.jar . 
hadoop fs -rmr $1
hadoop fs -put $1

hadoop fs -rmr tmp-avg
hadoop fs -rmr tmp-cls-0
hadoop fs -rmr tmp-cls-1
hadoop fs -rmr tmp-cls-2
hadoop fs -rmr tmp-cls-3
hadoop fs -rmr tmp-cls-4

pig -param SRCS=$1 label2.pig

rm -rf tmp-avg
rm -rf tmp-cls-0
rm -rf tmp-cls-1
rm -rf tmp-cls-2
rm -rf tmp-cls-3
rm -rf tmp-cls-4

hadoop fs -get tmp-avg
hadoop fs -get tmp-cls-0
hadoop fs -get tmp-cls-1
hadoop fs -get tmp-cls-2
hadoop fs -get tmp-cls-3
hadoop fs -get tmp-cls-4
