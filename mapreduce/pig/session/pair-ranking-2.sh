rm -rf pig_*
rm -rf tmp-osg
hadoop fs -rmr tmp-osg
hadoop fs -rmr tmp-sg
pig -param SRCS=$1 pair-ranking-2.pig
hadoop fs -get tmp-osg
