while read line; do

    hadoop fs -rmr $line
    hadoop fs -put $line
    hadoop fs -rmr dump-dns-$line-reduced
    
    pig -param SRCS=$line reduce.pig > dump-reduce-$1
    rm -rf dump-dns-$line-reduced
    hadoop fs -get dump-dns-$line-reduced
    ./restart.sh
done < $1

