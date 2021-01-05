date=$(date -d '1 day ago' "+%Y.%m.%d")
scp dump.txt.${date} 192.168.76.216:/mnt/data/hadoop/SINET/


#if [ $# != 1 ]; then
#    echo "usage: ./do.sh filename"
#    exit 1
#fi

#time hdfs dfs -put ${1}
time sbt -J-Xmx256G -J-Xms256G run #'run ${1}'
