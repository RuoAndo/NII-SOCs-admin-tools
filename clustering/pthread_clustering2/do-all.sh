#!/bin/bash

rm -rf tmp-repeat
touch tmp-repeat

#./top-cls.sh &

COUNT=0
while [ $COUNT -lt 3 ]; do
    ./first.sh $1
    ./second.sh 
    ./second.sh 
    ./second.sh 
    ./pickup-repeat.sh > tmp-repeat
    COUNT=`expr $COUNT + 1` 
done
