for line in `cat ${1}`
do
    echo $line
    hadoop dfsadmin -safemode leave
    rm -rf sip-$line
    hadoop fs -rmr sip-$line    
    hadoop fs -rmr $line
    hadoop fs -put $line
    pig -param SRCS=$line -param OUTPUTDIR=sip-$line sip.pig
    hadoop fs -get sip-$line
    ./restart.sh
done < $1

