while read line; do
    ./ip.sh $line
    echo "" 
    sleep 3s
done < $1
