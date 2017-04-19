#!/bin/sh

TESTFILE=$1
while read line; do
    echo $line
    # pig -param SRCS=$line addrpair.pig
    pig -param SRCS=$line -param IP=$2 detect5.pig
done < $TESTFILE


