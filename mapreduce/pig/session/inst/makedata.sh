split -l 30 $1 out
ls out* > list

rm -rf data2
touch data2

COUNT=0
DIFF=0
while read line; do
    #echo $line
    echo $DIFF
    echo $DIFF >> data2 
    cat $line >> data2
    
    if [ $COUNT -gt 3 ] ; then
	break
    fi

    #DIFF=`expr $DIFF + 0.25`
    DIFF=`echo "$DIFF + 0.25"|awk '{print $1 + $3}'`
    COUNT=`expr $COUNT + 1`
done < list
