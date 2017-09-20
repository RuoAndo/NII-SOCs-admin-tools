for line in `cat ${1}`
do
    hadoop dfsadmin -safemode leave
    ./fanout.sh $line
    ./restart.sh
done < $1
