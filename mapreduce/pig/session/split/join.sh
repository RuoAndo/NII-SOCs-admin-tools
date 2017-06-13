rm -rf addpair-join-$1
hadoop fs -rmr addpair-join-$1
pig -param DIRAVG=addrpair-avg-$1 -param DIRSID=addrpair-sid-$1 -param OUTPUTDIR=addrpair-join-$1 join.pig
hadoop fs -get addrpair-join-$1 
