while read line; do
    result=`echo $line | cut -d"," -f2`
    echo $result
done < $1
