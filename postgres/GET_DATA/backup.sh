currentDate=`date "+%Y%m%d-%H%M%S"`

echo "GET_DATA start:" $currentDate

COUNT=1

while [ $COUNT -lt 15 ]; do
    day=`echo date --date \'${COUNT} day ago\' +%Y/%m/%d`
    echo $day
    d=`eval ${day}`
    echo $d
   
    str=`echo ./getAlerts.sh "TARGET " \\"$d "00:00"\\" \\"$d "23:59"\\"`
    echo $str 
    eval ${str}

    day=`echo date --date \'${COUNT} day ago\' +%Y/%m/%d`
    echo $day
    d=`eval ${day}`
    echo $d
   
    str=`echo ./getAlerts.sh "ATTACK " \\"$d "00:00"\\" \\"$d "23:59"\\"`
    echo $str 
    eval ${str}

    COUNT=`expr $COUNT + 1` 
done


