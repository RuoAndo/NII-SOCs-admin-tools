#!/bin/sh

rm -rf tmp
touch tmp

TESTFILE=$1
while read line; do
    echo $line
    hadoop fs -rmr $line
    hadoop fs -put $line
    time ./pair-count-2.sh $line >> tmp
    #pig -param SRCS=$line addrpair.pig
    ./restart.sh
done < $TESTFILE

