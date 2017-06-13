#hadoop fs -rmr tmp-label
rm -rf tmp-label
pig -x local label.pig
