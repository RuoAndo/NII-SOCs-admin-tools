date_now=`date "+%Y%m%d-%H%M%S"`
date_start=`date "+%s"`
echo "started at:"$date_now 
echo "started at:"$date_now > procTime

time ./all.sh tmp-1000-1 300 8 10 6

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

\cp procTime procTime-300
\cp SSE SSE-300

#####

date_now=`date "+%Y%m%d-%H%M%S"`
date_start=`date "+%s"`
echo "started at:"$date_now 
echo "started at:"$date_now > procTime

time ./all.sh tmp-1000-1 1000 8 10 6

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

\cp procTime procTime-1000
\cp SSE SSE-1000

#####

date_now=`date "+%Y%m%d-%H%M%S"`
date_start=`date "+%s"`
echo "started at:"$date_now 
echo "started at:"$date_now > procTime

time ./all.sh tmp-1000-1 3000 8 10 6

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

\cp procTime procTime-3000
\cp SSE SSE-3000


