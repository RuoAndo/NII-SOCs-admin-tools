#!/bin/sh

if [ "$1" = "" ]
then
    echo "no argument: ./cat-liar.sh title"
    exit
fi

ls list-reduce* > list-list

today=$(date "+%Y%m%d")

rm -rf iplist_all_$1_$today
touch iplist_all_$1_$today

while read line; do
    echo $line
    cat $line >> iplist_all_$1_$today
done < list-list

\cp -r iplist_all_$1_$today ./reduced
\cp -r iplist_all_$1_$today iplist-all
