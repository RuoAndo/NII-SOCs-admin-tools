while read line; do
    ./fanout1.sh $line
done < $1
