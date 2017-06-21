rm -rf pig_*

TESTFILE=$1
while read line; do
    hadoop fs -put $line
    hadoop fs -rmr tuple-PF
    hadoop fs -rmr tuple-Q
    hadoop fs -rmr tuple-GGF
    #echo $line
    pig -param SRCS=$line tuple-1.pig
    pig tuple-2.pig
    pig tuple-3.pig
done < $1
