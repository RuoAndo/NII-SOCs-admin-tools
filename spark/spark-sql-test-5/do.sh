if [ $# != 1 ]; then
    echo "usage: ./do.sh filename"
    exit 1
fi

time hdfs dfs -put ${1}
time sbt -J-Xmx256G -J-Xms256G 'run ${1}'
