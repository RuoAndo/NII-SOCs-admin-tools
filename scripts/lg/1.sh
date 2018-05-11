if [ "$1" = "" ]
then
    echo "./1.sh date YYYYMMDD"
    exit
fi

cp sort.pl $1
cd $1

l1=`wc -l reduced-all* | cut -d " " -f 1` 
l2=`wc -l all | cut -d " " -f 1` 
RESULT=`echo "scale=5; $l1 / $l2" | bc`
ratio=`echo "scale=5; $RESULT * 100" | bc`

#echo "2"

procTime=`tail -n 3 log-1 | head -n 1 | cut -d "m" -f 1 | cut -d "l" -f 2 | sed 's/^[ \t]*//'`

echo "$1:$l2件:$l1組:$procTime分:${ratio}%"
#echo " "
#echo $1
#echo $l2
#echo $l1
#echo $procTime
#echo $ratio

echo " "

echo "all:"$l2
echo "<src,dst> pair:"$l1
echo "ratio:"$ratio"%"

head -n 3 reduced_1

ls log-* > list-log

rm -rf list-log-cut
touch list-log-cut

while read line; do
    t=`tail -n 3 $line | head -n 1`
    t2=`echo $t | cut -d "m" -f 1`
    t3=`echo $t2 | cut -d " " -f 2`
    p=`echo $line | cut -d "-" -f 2`
    echo $p","$t3 >> list-log-cut
done < list-log

./sort.pl list-log-cut | head -n 100 > list-log-cut-sorted
                                                                                                                          
while read line; do
    p1=`echo $line | cut -d "," -f 1`
    p2=`echo $line | cut -d "," -f 2`

    echo "process"$p1","$p2"m"

done < list-log-cut-sorted
