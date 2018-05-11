while read line; do
    echo $line | sed -e 's/\n/\n\n/g' 
done < $1
