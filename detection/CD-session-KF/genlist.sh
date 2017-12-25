#!/bin/bash
START_DATE=$1
END_DATE=$2

for (( DATE=${START_DATE} ; ${DATE} < ${END_DATE} ; DATE=`date -d "${DATE} 1 day" '+%Y%m%d'` )) ; do
  echo ${DATE}
done
