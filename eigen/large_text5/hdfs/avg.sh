./label.sh $1

hadoop fs -rmr $1
hadoop fs -put $1
hadoop fs -rmr $1-avg

pig -param SRCS=$1 avg.pig

rm -rf $1-avg
hadoop fs -get $1-avg

ls $1-avg/part-r-* > partlist

rm -rf avg-$1
while read line; do
    cat $line >> avg-$1
done < partlist

./sort.pl avg-$1 | tee c
