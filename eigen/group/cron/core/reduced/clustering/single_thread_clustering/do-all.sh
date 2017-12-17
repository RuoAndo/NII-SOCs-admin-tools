#!/bin/bash

rm -rf tmp-pickup
touch tmp-pickup

./top-cls.sh &

COUNT=0
while [ $COUNT -lt 1000 ]; do
    ./first.sh $1
    ./second.sh
    ./pickup-repeat.sh >> tmp-pickup
    COUNT=`expr $COUNT + 1` 
done
