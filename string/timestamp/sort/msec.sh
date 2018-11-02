# about 4 min
time split -l 100000000 all-org
./build-gpu.sh 8
./build-gpu.sh 9

rm -rf tmp-all
touch tmp-all

ls x* > list
while read line; do
    echo $line
    ./8 $line 100000000
    cat tmp >> tmp-all
done < list

nLines=`wc -l tmp-all`

# DATETIME=`date +%Y%m%d_%H%M%S`
DATETIME=`date +%Y%m%d`
time ./9 tmp-all $nLines
cp tmp msec-$DATETIME

time ./10 tmp-all $nLines
cp sorted sorted-msec-$DATETIME

scp msec-$DATETIME 192.168.72.5:/mnt/sdc/splunk-msec/
scp sorted-msec-$DATETIME 192.168.72.5:/mnt/sdc/splunk-msec/
