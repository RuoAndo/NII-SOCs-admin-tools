TESTFILE=$1
while read line; do
    hadoop fs -rmr $line
    hadoop fs -put $line
    echo $line
    ./session.sh $line $2
done < $1
 
