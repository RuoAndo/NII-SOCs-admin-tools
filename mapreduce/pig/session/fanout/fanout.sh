hadoop fs -rmr $1
hadoop fs -put $1

#hadoop fs -rmr dump-fanout

./piggybank.sh
pig -param SRCS=$1 fanout1.pig

rm -rf dump-fanout
hadoop fs -get dump-fanout

pig -param SRCS=dump-fanout fanout2.pig

rm -rf dump-fanout
hadoop fs -get dump-fanout
