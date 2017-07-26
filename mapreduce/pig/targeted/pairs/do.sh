#!/bin/sh

rm -rf tmp
touch tmp

for line in `cat ${1}`
do
    echo $line
    hadoop dfsadmin -safemode leave
    hadoop fs -rmr $line
    hadoop fs -put $line
    time ./pair-count-3.sh $line #>> tmp
    time ./pair-count-4.sh >> tmp
    #pig -param SRCS=$line addrpair.pig
    ./restart.sh
done

