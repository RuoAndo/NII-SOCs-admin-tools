while read line; do
    ./fanout.sh $line
    ./restart.sh
done < $1
