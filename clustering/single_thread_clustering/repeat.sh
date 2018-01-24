COUNTER=0

rm -rf tmp-repeat
touch tmp-repeat

while [ $COUNTER -ne 4 ]
do
    time ./first.sh $1
    time ./second.sh
    #time ./second.sh
    #time ./second.sh
    ./pickup-repeat.sh >> tmp-repeat
    COUNTER_BAK=`expr $COUNTER - 1`
    COUNTER=`expr $COUNTER + 1`
done
