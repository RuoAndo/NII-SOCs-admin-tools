t1=`date "+%Y-%m-%d %H:%M:%S"`
echo "START at:"$t1 

./build.sh group7

ls 2017* > list

COUNTER=0
for line in `cat list`
do
    echo "now processing " $line ":" $COUNTER " ..."
    #python trans.py $line > $COUNTER
    \cp $line $COUNTER
    COUNTER=`expr $COUNTER + 1`
done

./group7

t2=`date "+%Y-%m-%d %H:%M:%S"`
echo "FINISHED at:"$t2

diff=$(expr `date -d"$t2" +%s` - `date -d"$t1" +%s`)
echo "$diff"sec
