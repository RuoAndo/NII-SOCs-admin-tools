hadoop fs -rmr stmp
rm -rf stmp
pig -param SRCS=$1 capture-time.pig
