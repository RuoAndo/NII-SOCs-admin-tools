POINTS=10000000
PAIRS=10000

time python rand7.py 6 $POINTS $PAIRS > tmp-cont

for i in 5000 10000 100000
do
    date_start=`date "+%Y-%m-%d %H:%M:%S"`
    echo "started at:"$date_start 
    echo "started at:"$date_start > procTime-cont

    #time ./all.sh tmp-cont-1000-1 i 8 10 6
    time ./zero.sh tmp-cont $i # 6000 Thread
    #time ./zero.sh tmp-1000-1 5000 # 6000 Thread
    #time ./zero.sh tmp-1000-1 10000 # 3000 Thread
    #time ./zero.sh tmp-1000-1 100000 # 300 Thread
    
    date_end=`date "+%Y-%m-%d %H:%M:%S"`
    echo "finished at:"$date_end
    echo "finished at:"$date_end >> procTime-cont

    # t1='2014-01-28 01:00:00'
    diff=$(expr `date -d"$date_end" +%s` - `date -d"$date_start" +%s`)

    echo "$diff"sec >> procTime-cont
    echo `expr "$diff" / 60`min >> procTime-cont
    
    \cp procTime-cont procTime-cont-${POINTS}-${PAIRS}-$i
    \cp SSE SSE-cont-${POINTS}-${PAIRS}-$i
done

\cp reduced reduced-${POINTS}-${PAIRS}

## km org

for i in 300 3000 6000
do
    date_start=`date "+%Y-%m-%d %H:%M:%S"`
    echo "started at:"$date_start 
    echo "started at:"$date_start > procTime

    time ./all.sh tmp-cont $i 8 10 6

    date_end=`date "+%Y-%m-%d %H:%M:%S"`
    echo "finished at:"$date_end
    echo "finished at:"$date_end >> procTime

    # t1='2014-01-28 01:00:00'
    diff=$(expr `date -d"$date_end" +%s` - `date -d"$date_start" +%s`)

    echo "$diff"sec >> procTime
    echo `expr "$diff" / 60`min >> procTime
    
    \cp procTime procTime-km-${POINTS}-${PAIRS}-$i
    \cp SSE SSE-km-${POINTS}-${PAIRS}-$i
done

## km cont

for i in 300 3000 6000
do
    date_start=`date "+%Y-%m-%d %H:%M:%S"`
    echo "started at:"$date_start 
    echo "started at:"$date_start > procTime

    time ./all.sh reduced-${POINTS}-${PAIRS} $i 8 10 6

    date_end=`date "+%Y-%m-%d %H:%M:%S"`
    echo "finished at:"$date_end
    echo "finished at:"$date_end >> procTime

    # t1='2014-01-28 01:00:00'
    diff=$(expr `date -d"$date_end" +%s` - `date -d"$date_start" +%s`)

    echo "$diff"sec >> procTime
    echo `expr "$diff" / 60`min >> procTime
    
    \cp procTime procTime-km-cont-${POINTS}-${PAIRS}-$i
    \cp SSE SSE-km-cont-${POINTS}-${PAIRS}-$i
done

#########
#########
