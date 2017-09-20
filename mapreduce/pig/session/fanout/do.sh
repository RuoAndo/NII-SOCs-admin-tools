for line in `cat ${1}`
do
    ./fanout.sh $line
    ./restart.sh
done < $1
