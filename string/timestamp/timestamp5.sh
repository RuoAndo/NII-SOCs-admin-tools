#!/bin/bash

if [ "$1" = "" ]
then
    echo "./timestamp.sh nLines DIR"
    exit 1
fi

DATE=`date --date '3 day ago' +%Y%m%d`
echo "timestamp:"${DATE}

cp timestamp5.sh ./${DATE}/
cp timestamp5.cpp ./${DATE}/
cp build.sh ./${DATE}/
cp csv.cpp ./${DATE}/
cp csv.hpp ./${DATE}/
cp utility.h ./${DATE}/

cd ${DATE}

if [ "$1" = "" ]
then
    echo "./timestamp5.sh nLines"
    exit 1
fi

./build.sh timestamp5

time split -l $1 all-org
ls x* > list

rm -rf timestamp-all-${DATE}
touch timestamp-all-${DATE}

while read line; do
    echo $line
    nLines=`wc -l $line | cut -d " " -f 1`
    ./timestamp5 $line $nLines
    cat tmp-timestamp >> timestamp-all-${DATE}
done < list

scp timestamp-all-${DATE} 192.168.72.5:/mnt/sdc/splunk-session/$2
