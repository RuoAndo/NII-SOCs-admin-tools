for line in `cat ${1}`
do
    echo $line
    hadoop fs -put $line
    ./addrpair.sh $line
    ./addrpair-join.sh $line
    ./addrpair-sid.sh $line
    ./addrpair-avg.sh $line
    ./join.sh $line
    ./restart.sh
done



