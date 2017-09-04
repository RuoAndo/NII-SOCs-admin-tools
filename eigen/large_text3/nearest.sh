hadoop fs -rmr $1
hadoop fs -put $1

hadoop fs -rmr $2
hadoop fs -put $2

pig -param CENTROID=$1 -param ALL2=$2 nearest.pig

