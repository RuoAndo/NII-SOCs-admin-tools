rm -rf addrpair-sid-$1
hadoop fs -rmr addrpair-sid-$1
pig -x local -param OUTPUTDIR=addrpair-sid-$1 addrpair-sid.pig
hadoop fs -get addrpair-sid-$1
