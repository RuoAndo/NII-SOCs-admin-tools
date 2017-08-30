hadoop fs -rmr $1
hadoop fs -put $1
hadoop fs -rmr $1-avg

pig -param SRCS=$1 avg2.pig

rm -rf $1-avg
hadoop fs -get $1-avg
\cp $1-avg/part-r-00000 avg-$1
cat avg-$1 | tee c
\cp c c.rand 
