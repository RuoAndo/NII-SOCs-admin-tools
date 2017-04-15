#!/bin/sh

TESTFILE=$1
while read line; do
    echo $line
    ./elapsed_time_avg_byte.sh $line 47.88.136.144 $line
done < $TESTFILE

