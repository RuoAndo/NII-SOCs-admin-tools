# about 4 min
time split -l 100000000 all-org
./build-gpu.sh 6
./build-gpu.sh 7

rm -rf tmp-all
touch tmp-all

ls x* > list
while read line; do
    echo $line
    ./6 $line 100000000
    cat tmp >> tmp-all
done < list

nLines=`wc -l tmp-all`

# DATETIME=`date +%Y%m%d_%H%M%S`
DATETIME=`date +%Y%m%d`
time ./7 tmp-all $nLines
cp tmp sec-$DATETIME

scp sec-$DATETIME 192.168:72.5:/mnt/sdc/splunk-sec/
