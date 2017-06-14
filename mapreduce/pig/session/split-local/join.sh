rm -rf addrpair-join-$1
hadoop fs -rmr addrpair-join-$1
pig -x local -param DIRAVG=addrpair-avg-$1 -param DIRSID=addrpair-sid-$1 -param OUTPUTDIR=addrpair-join-$1 join.pig
hadoop fs -get addrpair-join-$1 
