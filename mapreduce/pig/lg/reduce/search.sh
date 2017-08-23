while read line; do
    #echo $line
    grep $line $2
done < $1
