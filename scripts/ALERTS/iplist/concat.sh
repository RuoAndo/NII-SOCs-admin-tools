#!/bin/bash

if [ "$3" = "" ]
then
    echo "./concat.sh alert_type"
fi

START_DATE=20180521
#`date --date "30 days ago" +%Y%m%d` 
END_DATE=`date --date "2 days ago" +%Y%m%d` 
NEW_DATE=`date --date "1 days ago" +%Y%m%d` 
ALERT_TYPE=$1

echo "start date:"$START_DATE
echo "end date:"$END_DATE
echo "new date:"$NEW_DATE

rm -rf iplist-${ALERT_TYPE}-${START_DATE}-${END_DATE}
touch iplist-${ALERT_TYPE}-${START_DATE}-${END_DATE}

for (( DATE=${START_DATE} ; ${DATE} < ${END_DATE} ; DATE=`date -d "${DATE} 1 day" '+%Y%m%d'` )) ; do
  #echo iplist-${ALERT_TYPE}-${DATE}
  cat iplist-${ALERT_TYPE}-${DATE} >> iplist-concat-${ALERT_TYPE}-${START_DATE}-${END_DATE}
done

python diff.py iplist-concat-${ALERT_TYPE}-${START_DATE}-${END_DATE} iplist-${ALERT_TYPE}-${NEW_DATE} ${NEW_DATE} > /mnt/sdc/iplist-new/iplist-new-${ALERT_TYPE}-${START_DATE}-${END_DATE}-${NEW_DATE}

wc -l /mnt/sdc/iplist-new/iplist-new-${ALERT_TYPE}-${START_DATE}-${END_DATE}-${NEW_DATE}
