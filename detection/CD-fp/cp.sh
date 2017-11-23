ls -L1 /data1/count_Alarm_Each/FirePOWER | grep 2017 | grep -v csv > list

while read line; do
    echo "copying "$line
    cp -r /data1/count_Alarm_Each/FirePOWER/${line}_30 .
done < list
