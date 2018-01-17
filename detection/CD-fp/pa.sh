today=$(date "+%Y%m%d")
day=`date --date '1 day ago' +%Y%m%d`
#echo $today
./count_Alarm_Each_PaloAlto.sh $day 30
