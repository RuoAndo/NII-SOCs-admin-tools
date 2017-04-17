#!/bin/sh

TESTFILE=$1
while read line; do
    echo $line
    ./targeted_desc.sh $line $line
done < $TESTFILE

