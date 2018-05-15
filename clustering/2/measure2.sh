POINTS=10000000
PAIRS=10000

time python rand7.py 6 $POINTS $PAIRS > tmp-km

for i in 300 3000 6000
do
    date_start=`date "+%Y-%m-%d %H:%M:%S"`
    echo "started at:"$date_start 
    echo "started at:"$date_start > procTime

    time ./all.sh tmp-km $i 8 10 6

    date_end=`date "+%Y-%m-%d %H:%M:%S"`
    echo "finished at:"$date_end
    echo "finished at:"$date_end >> procTime

    # t1='2014-01-28 01:00:00'
    diff=$(expr `date -d"$date_end" +%s` - `date -d"$date_start" +%s`)

    echo "$diff"sec >> procTime
    echo `expr "$diff" / 60`min >> procTime
    
    \cp procTime procTime-${POINTS}-${PAIRS}-$i
    \cp SSE SSE-${POINTS}-${PAIRS}-$i
done


