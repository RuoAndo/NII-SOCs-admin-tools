while read line; do
    \cp /data1/count_Alarm_Each/FirePOWER/"$line"_30/* .
    #time python rnn.py $line
done < $1
