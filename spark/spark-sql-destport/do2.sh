date=$(date -d '1 day ago' "+%Y.%m.%d")

#hdfs dfs -ls  -h
#hdfs dfs -rm dump.txt.${date}

#time hdfs dfs -put /mnt/data/hadoop/SINET/dump.txt.${date}
#hdfs dfs -ls  -h

#if [ $# != 1 ]; then
#    echo "usage: ./do.sh filename"
#    exit 1
#fi

time sbt -J-Xmx256G -J-Xms256G "run dump.txt.${date}"
