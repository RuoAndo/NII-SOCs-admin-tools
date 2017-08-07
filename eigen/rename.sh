COUNTER=0
for line in `cat ${1}`
do
    mv $line $COUNTER

    COUNTER=`expr $COUNTER + 1`
done
