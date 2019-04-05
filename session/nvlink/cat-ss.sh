#!/bin/bash

if [ "$2" = "" ]
then
    echo "usage: ./cat-ss.sh START END"
    exit 1
fi

START_DATE=$1
END_DATE=$2

rm -rf session-all-${START_DATE}-${END_DATE}
touch session-all-${START_DATE}-${END_DATE}

for (( DATE=${START_DATE} ; ${DATE} < ${END_DATE} ; DATE=`date -d "${DATE} 1 day" '+%Y%m%d'` )) ; do
    echo ${DATE}
    cd ${DATE}
    cat all-org >> ../session-all-${START_DATE}-${END_DATE}
    cd ..
done

#TESTFILE=./hoge.txt
#while read line; do
#    echo $line
#    done < $TESTFILE
