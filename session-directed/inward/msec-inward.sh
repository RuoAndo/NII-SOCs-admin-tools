# msec.sh - 8 axnd 9

# about 4 min
DATE=`date --date '4 day ago' +%Y%m%d`  
echo $DATE
#cp ${DATE}/all-org .
#directed_msec_inward-all_20190221

rm -rf x*

time split -l 100000000 directed_msec_inward-all_${DATE}
./build-gpu.sh 8-inward
./build-gpu.sh 9-inward

rm -rf tmp-all
touch tmp-all

ls x* > list
while read line; do
    echo $line
    time CUDA_VISIBLE_DEVICES=0 ./8-inward $line 100000000
    cat tmp-inward >> tmp-inward-all
done < list

nLines=`wc -l tmp-inward-all`

# DATETIME=`date +%Y%m%d_%H%M%S`
#DATETIME=`date +%Y%m%d`
time CUDA_VISIBLE_DEVICES=1 ./9-inward tmp-inward-all $nLines
cp tmp-inward msec-inward-${DATE}
cp raw-inward raw-inward-${DATE}

scp msec-inward-${DATE} 192.168.72.6:/mnt/sdc/splunk-session-directed/inward/gpu02/
scp msec-inward-${DATE} 192.168.72.6:/mnt/sdc/splunk-session-directed/inward/current
scp raw-inward-${DATE} 192.168.72.6:/mnt/sdc/splunk-session-directed/inward/gpu02/raw/

mv msec-inward-${DATE} ./backup
mv raw-inward-${DATE} ./backup
