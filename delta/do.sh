split -l 100000 all -d -a 5
date_now=`date "+%Y%m%d-%H%M%S"`
date_start=`date "+%s"`

echo "started at:"$date_now 
echo "started at:"$date_now > procTime
time ./delta3

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
