rm -rf tmp-diff
hadoop fs -rmr tmp-label-2
hadoop fs -rmr tmp-diff
pig repeat.pig
hadoop fs -rmr tmp-label
hadoop fs -cp tmp-label-2 tmp-label
hadoop fs -get tmp-diff
diff=`more tmp-diff/part-*`
echo "diff:" $diff



