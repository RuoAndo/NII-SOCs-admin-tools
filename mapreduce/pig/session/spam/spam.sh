hadoop fs -rmr $1
hadoop fs -put $1

hadoop fs -rmr spam-PF
pig -param SRCS=$1 spam.pig

rm -rf spam-PF
hadoop fs -get spam-PF
