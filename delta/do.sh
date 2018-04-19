echo x* | xargs rm
echo d* | xargs rm
echo s* | xargs rm

rm -rf delta
rm -rf delta-sorted

./build.sh delta3

echo "now splitting file..."
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

echo "now sorting..."

./sort.pl delta > delta-sorted
