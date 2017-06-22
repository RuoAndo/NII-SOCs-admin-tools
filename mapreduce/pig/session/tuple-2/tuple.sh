rm -rf pig_*

TESTFILE=$1
while read line; do
    hadoop fs -put $line
    #hadoop fs -rmr tuple-PF
    #hadoop fs -rmr tuple-Q
    #hadoop fs -rmr tuple-QGF
    #hadoop fs -rmr tuple-$line
    #echo $line
    #pig -param SRCS=$line tuple-1.pig
    pig -param SRCS=$line tuple.pig
    #pig tuple-2.pig
    #pig -param OUTPUTDIR=tuple-$line tuple-3.pig 
done < $1
