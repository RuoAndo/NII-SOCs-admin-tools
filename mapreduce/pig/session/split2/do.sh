TESTFILE=$1
while read line; do
    echo $line
    hadoop fs -put $line
    ./addrpair.sh $line
    ./addrpair-join.sh $line
    #./addrpair-sid.sh $line
    #./addrpair-avg.sh $line
    #./join.sh $line
done < $1

