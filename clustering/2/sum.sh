SUM=0
while read line; do
    echo $line
    SUM=`expr $SUM + $line`
done < $1

echo $SUM
