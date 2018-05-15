
time python rand7.py 6 10000000 10000 > tmp-1000-1

for i in 300
do
    date_start=`date "+%Y%m%d-%H%M%S"`
    echo "started at:"$date_start 
    echo "started at:"$date_start > procTime

    time ./all.sh tmp-1000-1 i 8 10 6

    date_end=`date "+%Y-%m-%d-%H:%M:%S"`
    echo "finished at:"$date_end
    echo "finished at:"$date_end >> procTime

    # t1='2014-01-28 01:00:00'
    diff=$(expr `date -d"$date_end" +%s` - `date -d"$date_start" +%s`)

    \cp procTime procTime-10000000-10000-$i
    \cp SSE SSE-10000000-10000-$i
done


