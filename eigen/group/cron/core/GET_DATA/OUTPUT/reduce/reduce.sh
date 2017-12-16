hadoop fs -rmr $1
hadoop fs -put $1

hadoop fs -rmr reduce-PF
hadoop fs -rmr reduce-dump

pig -param SRCS=$1 reduce.pig

rm -rf reduce-PF
hadoop fs -get reduce-PF

rm -rf reduce-dump
hadoop fs -get reduce-dump
