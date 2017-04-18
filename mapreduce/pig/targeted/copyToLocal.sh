#!/bin/sh

TESTFILE=$1
while read line; do
    echo $line
    #./elapsed_time.sh $line 47.88.136.144 $line
    hadoop fs -copyToLocal $line.dump
done < $TESTFILE

