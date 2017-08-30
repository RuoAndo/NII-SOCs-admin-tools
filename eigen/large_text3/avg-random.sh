./label.sh $1

hadoop fs -rmr $1
hadoop fs -put $1
hadoop fs -rmr $1-avg

pig -param SRCS=$1 avg-random.pig

rm -rf $1-avg
hadoop fs -get $1-avg
cp $1-avg/part-r-00000 avg-$1
cat avg-$1 
cp avg-$1 c-rand

