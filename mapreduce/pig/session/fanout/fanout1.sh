hadoop fs -rmr $1
hadoop fs -put $1

#hadoop fs -rmr dump-fanout

./piggybank.sh
pig -param SRCS=$1 fanout1.pig

rm -rf dump_fanout_$1
hadoop fs -get dump_fanout_$1

./restart.sh

hadoop fs -rmr dump_fanout_2-$1
pig -param SRCS=dump_fanout_$1 fanout2.pig

./restart.sh

#pig -param SRCS=dump-fanout fanout2.pig
#rm -rf dump-fanout
#hadoop fs -get dump-fanout
