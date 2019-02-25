# msec.sh - 8 and 9

# about 4 min
DATE=`date --date '4 day ago' +%Y%m%d`  
echo $DATE
#cp ${DATE}/all-org .
#directed_msec_outward-all_20190221

rm -rf x*

time split -l 100000000 directed_msec_outward-all_${DATE}
./build-gpu.sh 8-outward
./build-gpu.sh 9-outward

rm -rf tmp-all
touch tmp-all

ls x* > list
while read line; do
    echo $line
    CUDA_VISIBLE_DEVICES=1 ./8-outward $line 100000000
    cat tmp-outward >> tmp-outward-all
done < list

nLines=`wc -l tmp-outward-all`

# DATETIME=`date +%Y%m%d_%H%M%S`
#DATETIME=`date +%Y%m%d`
time CUDA_VISIBLE_DEVICES=1 ./9-outward tmp-outward-all $nLines
cp tmp-outward msec-outward-${DATE}
cp raw-outward raw-outward-${DATE}

scp msec-outward-${DATE} 192.168.72.6:/mnt/sdc/splunk-session-directed/outward
scp msec-outward-${DATE} 192.168.72.6:/mnt/sdc/splunk-session-directed/outward/current
scp raw-outward-${DATE} 192.168.72.6:/mnt/sdc/splunk-session-directed/outward/raw

mv msec-outward-${DATE} ./backup
mv raw-outward-${DATE} ./backup
