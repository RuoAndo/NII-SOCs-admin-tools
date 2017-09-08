hadoop fs -rmr $1
hadoop fs -put $1
hadoop fs -rmr $1-avg

pig -param SRCS=$1 avg2.pig

rm -rf $1-avg
hadoop fs -get $1-avg
#\cp $1-avg/part-r-00000 avg-$1

ls $1-avg/part-r-* > partlist

rm -rf avg-$1
touch avg-$1
while read line; do
    cat $line >> avg-$1
done < partlist

./sort.pl avg-$1 > tmp-sort
cp tmp-sort avg-$1
