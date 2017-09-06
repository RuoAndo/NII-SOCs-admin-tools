./piggybank.sh

hadoop fs -rmr $1
hadoop fs -put $1

hadoop fs -rmr dump-dns-$1
pig -param SRCS=$1 dns.pig

rm -rf dump-dns-$1
hadoop fs -get dump-dns-$1
