#!/bin/sh

TESTFILE=$1
while read line; do
    cut=`echo $line | cut -d ":" -f 1`
    line=`expr $cut + 1`
    #echo $line
    head -$line $2 | tail -1
done < $TESTFILE
