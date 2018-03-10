split -l 1000000 tmp bk
ls bk* > list

COUNTER=0
while read line; do
    echo $line "->" $COUNTER
    cp $line $COUNTER
    COUNTER=`expr $COUNTER + 1`
done < list
