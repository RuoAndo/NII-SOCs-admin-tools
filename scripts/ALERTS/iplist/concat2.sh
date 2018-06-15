#!/bin/bash

if [ "$3" = "" ]
then
    echo "./concat.sh alert_type"
fi

COUNT=25
while [ $COUNT -gt 8 ]; do
    COUNT2=`expr $COUNT - 7`
    echo $COUNT","$COUNT2
    COUNT=`expr $COUNT - 1` 

    START_DATE=`date --date "${COUNT} days ago" +%Y%m%d` 
    END_DATE=`date --date "${COUNT2} days ago" +%Y%m%d` 
    ALERT_TYPE=$1

    rm -rf iplist-${ALERT_TYPE}-${START_DATE}-${END_DATE}
    touch iplist-${ALERT_TYPE}-${START_DATE}-${END_DATE}

    for (( DATE=${START_DATE} ; ${DATE} < ${END_DATE} ; DATE=`date -d "${DATE} 1 day" '+%Y%m%d'` )) ; do
	echo iplist-${ALERT_TYPE}-${DATE}
	cat iplist-${ALERT_TYPE}-${DATE} >> iplist-concat-${ALERT_TYPE}-${START_DATE}-${END_DATE}
    done

    python diff.py iplist-concat-${ALERT_TYPE}-${START_DATE}-${END_DATE} iplist-${ALERT_TYPE}-${DATE} ${DATE} > /mnt/sdc/iplist-new/iplist-new-${ALERT_TYPE}-${DATE}

done
