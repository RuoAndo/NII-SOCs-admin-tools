COUNT=0
while read line; do
    cat $line
    COUNT=`expr $COUNT + 1` 
done < $1
