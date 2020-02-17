currentDate=`date "+%Y%m%d-%H%M%S"`

echo "GET_DATA start:" $currentDate

day=`date --date '1 day ago' +%Y/%m/%d`
str=`echo ./getAlerts.sh "TARGET " \\"$day "00:00"\\" \\"$day "23:59"\\"`
echo $str 
eval ${str}

day=`date --date '1 day ago' +%Y/%m/%d`
str=`echo ./getAlerts.sh "ATTACK " \\"$day "00:00"\\" \\"$day "23:59"\\"`
echo $str 
eval ${str}





