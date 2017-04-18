#!/bin/sh

TESTFILE=$1
while read line; do
    echo $line
    pig -param SRCS=$line addrpair.pig
done < $TESTFILE

