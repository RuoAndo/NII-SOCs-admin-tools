#!/bin/sh

if [ "$1" = "" ]
then
    echo "no argument: ./cat-reduce.sh title"
    exit
fi

ls reduce-* > reduce-list

today=$(date "+%Y%m%d")

rm -rf reduce_all
touch reduce_all

while read line; do
    echo $line
    cat $line >> reduce_all_$1_$today
done < reduce-list
