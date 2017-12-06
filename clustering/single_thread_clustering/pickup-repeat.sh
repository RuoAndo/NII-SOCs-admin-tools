COUNTER=0
COUNTER_BAK=0

a=1
while [ $a -ne 20 ]
do
    ./pickup.sh $a
    a=`expr $a + 1`
done
