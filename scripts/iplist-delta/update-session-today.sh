ls delta-sorted-20180* > list-delta
tail -n 14 list-delta 
tail -n 14 list-delta > list-delta-tail

rm -rf procTime
touch procTime

while read line; do
    echo $line

    echo $line >> procTime

    date_now=`date "+%Y%m%d-%H%M%S"`
    date_start=`date "+%s"`
    echo "started at:"$date_now 
    echo "started at:"$date_now >> procTime

    python update-session.py $line

    date_now=`date "+%Y%m%d-%H%M%S"`
    echo "finished at:"$date_now
    echo "finished at:"$date_now >> procTime
    date_end=`date "+%s"`

    diff=`echo $((date_end-date_start))`
    div=`echo $((diff/60))`

    echo "proc time:"$diff"sec" 
    echo "proc time:"$div"min" 

    echo "proc time:"$diff"sec" >> procTime
    echo "proc time:"$div"min" >> procTime

done < list-delta-tail
