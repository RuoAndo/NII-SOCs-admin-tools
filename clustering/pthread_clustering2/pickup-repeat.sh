nClusters=20

COUNTER=0
COUNTER_BAK=0

echo "concatenating all reduced files..."

a=0
rm -rf all
touch all
while [ $a -ne $nClusters ]
do
    cat $a >> all
    a=`expr $a + 1`
done

echo "done"
wc -l all

a=1
while [ $a -ne $nClusters ]
do
    #echo "processing " $a " cluster..."
    ./pickup2.sh $a
    a=`expr $a + 1`
done
