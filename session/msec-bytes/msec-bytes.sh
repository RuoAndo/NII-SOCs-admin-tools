# about 4 min
DATE=`date --date '3 day ago' +%Y%m%d`  
echo $DATE
cp ${DATE}/all-org .

rm -rf x*

time split -l 100000000 all-org
./build-gpu.sh 11
./build-gpu.sh 9

rm -rf tmp-all
touch tmp-all

ls x* > list
while read line; do
    echo $line
    CUDA_VISIBLE_DEVICES=1 ./11 $line 100000000
    cat tmp >> tmp-all
done < list

nLines=`wc -l tmp-all`

# DATETIME=`date +%Y%m%d_%H%M%S`
#DATETIME=`date +%Y%m%d`
time CUDA_VISIBLE_DEVICES=1 ./9 tmp-all $nLines
cp tmp msec-bytes-${DATE}
cp raw raw-bytes-${DATE}

scp msec-bytes-${DATE} 192.168.72.6:/mnt/sdc/splunk-msec-bytes/
scp msec-bytes-${DATE} 192.168.72.6:/mnt/sdc/splunk-msec-bytes/current
scp raw-bytes-${DATE} 192.168.72.6:/mnt/sdc/splunk-msec-bytes/raw/

mv msec-bytes-${DATE} ./backup
mv raw-bytes-${DATE} ./backup
