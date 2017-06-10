rm -rf tmp-bytes
hadoop fs -rmr tmp-bytes
pig bytes.pig
hadoop fs -get tmp-bytes
