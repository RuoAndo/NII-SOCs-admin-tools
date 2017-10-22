COUNTER=0
while read line; do
    python trans.py $line > $line-trans
    COUNTER=`expr $COUNTER + 1`
    #echo $COUNTER

    while read line2; do
	echo $COUNTER","$line2
    done < $line-trans
    
done < $1
