#!/bin/bash
count=$1
while true
do
  #comstr="`date --date '$1 day ago' +%Y%m%d`"
  comstr="'$count day ago' +%Y%m%d"

  #`date --date '1 day ago' +%Y%m%d`
  comstr2="date --date $comstr"
  #echo $comstr2
  
  eval $comstr2
  #echo $d

  count=`expr $count - 1`
  if [ $count -eq 2 ]; then
    exit 0
  fi
done
