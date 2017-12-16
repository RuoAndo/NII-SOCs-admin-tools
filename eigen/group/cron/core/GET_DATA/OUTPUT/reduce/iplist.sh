#!/bin/sh

if [ "$1" = "" ]
then
    echo "no argument: ./iplist.sh FILE(tmp4)"
    exit
fi


today=$(date "+%Y%m%d")
python iplist.py $1 > iplist_$today
\cp iplist_$today ./reduced/
