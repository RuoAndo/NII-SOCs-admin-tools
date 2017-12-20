COUNT=0
while read line; do
    #echo $line
    gr=`grep $line $2`
    
    if [ ${#gr} -gt 1 ] ; then
	echo $gr
	COUNT=`expr $COUNT + 1` 
    fi
done < $1

echo $COUNT
