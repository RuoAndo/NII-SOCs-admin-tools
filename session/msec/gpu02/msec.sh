# msec.sh - 8 axnd 9

# about 4 min
DATE=`date --date '4 day ago' +%Y%m%d`  
echo $DATE
#cp ${DATE}/all-org .
#directed_msec_inward-all_20190221

cp ../trans-pair-all-${DATE} .

rm -rf x*

time split -l 100000000 trans-pair-all-${DATE}
./build-gpu.sh 8
./build-gpu.sh 9

rm -rf tmp-all
touch tmp-all

ls x* > list
while read line; do
    echo $line
    time CUDA_VISIBLE_DEVICES=1 ./8 $line 100000000
    cat tmp >> tmp-all
done < list

nLines=`wc -l tmp-all | cut -d " " -f 1`

# DATETIME=`date +%Y%m%d_%H%M%S`
#DATETIME=`date +%Y%m%d`
time CUDA_VISIBLE_DEVICES=1 ./9 tmp-all $nLines
cp tmp msec-${DATE}
cp raw raw-${DATE}

scp msec-${DATE} 192.168.72.6:/mnt/sdc/splunk-msec/gpu02/
scp msec-${DATE} 192.168.72.6:/mnt/sdc/splunk-msec/gpu02/current
scp raw-${DATE} 192.168.72.6:/mnt/sdc/splunk-msec/gpu02/raw/

mv msec-${DATE} ./backup
mv raw-${DATE} ./backup

rm -rf trans-pair-all-${DATE}
