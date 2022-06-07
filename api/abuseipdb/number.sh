COUNT=1
while read line; do
    echo $COUNT","$line
    COUNT=`expr $COUNT + 1`

done < $1
