####### 1 ########

hadoop fs -rmr $1 #1
hadoop fs -put $1 #2
hadoop fs -rmr dump_fanout1_$1 #3

./piggybank.sh
###
pig -param SRCS=$1 fanout1.pig # STORE R INTO 'dump_fanout1_$SRCS' USING PigStorage(',');
###

rm -rf dump_fanout1_$1
hadoop fs -get dump_fanout1_$1 #4

######## 2 ########

/dump_fanout2_outaa 
hadoop fs -rmr dump_fanout2_$1 #5
###
pig -param SRCS=$1 fanout2.pig # STORE fanout INTO 'dump_fanout2-$SRCS';
###

rm -rf dump_fanout2_$1 #6 < #5 
hadoop fs -get dump_fanout2_$1 #7

#./restart.sh
