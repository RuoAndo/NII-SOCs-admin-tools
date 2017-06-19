line=`expr $2 + 1`
echo $line
head -$line $1 | tail -1
