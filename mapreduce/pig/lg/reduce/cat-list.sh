#!/bin/sh

if [ "$1" = "" ]
then
    echo "no argument: ./cat-liar.sh title"
    exit
fi

ls list-reduce* > list-list

today=$(date "+%Y%m%d")

rm -rf list_all_$1_$today
touch list_all_$1_$today

while read line; do
    echo $line
    cat $line >> list_all_$1_$today
done < list-list
