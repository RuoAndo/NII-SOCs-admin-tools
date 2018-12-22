# about 4 min
DATE=`date --date '3 day ago' +%Y%m%d`  
echo $DATE
cp ${DATE}/all-org .

rm -rf x*

time split -l 100000000 all-org
./build-gpu.sh 10
./build-gpu.sh 7

rm -rf tmp-all
touch tmp-all

ls x* > list
while read line; do
    echo $line
    ./10 $line 100000000
    cat tmp >> tmp-all
done < list

nLines=`wc -l tmp-all`

#DATETIME=`date +%Y%m%d_%H%M%S`
#DATETIME=`date +%Y%m%d`
time ./7 tmp-all $nLines
cp tmp sec-bytes-${DATE}
cp raw raw-bytes-${DATE}

#scp sec-${DATE} 192.168.72.6:/mnt/sdc/splunk-sec/
#scp sec-${DATE} 192.168.72.6:/mnt/sdc/splunk-sec/current
#scp raw-${DATE} 192.168.72.6:/mnt/sdc/splunk-sec/raw/

scp sec-bytes-${DATE} 192.168.72.6:/mnt/sdc/splunk-sec-bytes/
scp sec-bytes-${DATE} 192.168.72.6:/mnt/sdc/splunk-sec-bytes/current
scp raw-bytes-${DATE} 192.168.72.6:/mnt/sdc/splunk-sec-bytes/raw/
