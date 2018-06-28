#!/bin/bash

if [ "$1" = "" ]
then
    echo "./concat.sh alert_type"
    exit
fi

START_DATE=20180521
#`date --date "30 days ago" +%Y%m%d` 
END_DATE=`date --date "2 days ago" +%Y%m%d` 
NEW_DATE=`date --date "1 days ago" +%Y%m%d` 
ALERT_TYPE=$1

echo "start date:"$START_DATE" -> end date:"$END_DATE" - new date:"$NEW_DATE

rm -rf iplist-concat-${ALERT_TYPE}-${START_DATE}-${END_DATE}
touch iplist-concat-${ALERT_TYPE}-${START_DATE}-${END_DATE}

for (( DATE=${START_DATE} ; ${DATE} < ${END_DATE} ; DATE=`date -d "${DATE} 1 day" '+%Y%m%d'` )) ; do
  #echo iplist-${ALERT_TYPE}-${DATE}
  cat iplist-${ALERT_TYPE}-${DATE} >> iplist-concat-${ALERT_TYPE}-${START_DATE}-${END_DATE}
done

wc -l iplist-concat-${ALERT_TYPE}-${START_DATE}-${END_DATE} 
wc -l iplist-${ALERT_TYPE}-${NEW_DATE} 

python diff.py iplist-concat-${ALERT_TYPE}-${START_DATE}-${END_DATE} iplist-${ALERT_TYPE}-${NEW_DATE} ${NEW_DATE} > /mnt/sdc/iplist-new/iplist-new-${ALERT_TYPE}-${START_DATE}-${END_DATE}-${NEW_DATE}

wc -l /mnt/sdc/iplist-new/iplist-new-${ALERT_TYPE}-${START_DATE}-${END_DATE}-${NEW_DATE}
