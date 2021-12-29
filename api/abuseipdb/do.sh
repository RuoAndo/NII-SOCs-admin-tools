while read line; do
    ./ip.sh $line
    sleep 3s
done < $1
