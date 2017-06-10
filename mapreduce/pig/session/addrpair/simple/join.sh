rm -rf tmp-join
hadoop fs -rmr tmp-join
pig join.pig
hadoop fs -get tmp-join
