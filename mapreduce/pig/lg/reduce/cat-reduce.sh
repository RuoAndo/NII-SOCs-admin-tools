#!/bin/sh

if [ "$1" = "" ]
then
    echo "no argument: ./cat-reduce.sh title"
    exit
fi

ls reduce-* > reduce-list

today=$(date "+%Y%m%d")

rm -rf reduce_all_$1_$today
touch reduce_all_$1_$today

while read line; do
    echo $line
    cat $line >> reduce_all_$1_$today
done < reduce-list

\cp reduce_all_$1_$today ./reduced/
\cp reduce_all_$1_$today reduce_all
