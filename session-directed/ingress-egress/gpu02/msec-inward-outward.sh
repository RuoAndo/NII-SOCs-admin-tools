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

rm -rf tmp-inward-all
touch tmp-inward-all

ls x* > list
while read line; do
    echo $line
    time CUDA_VISIBLE_DEVICES=0 ./8-inward $line 100000000
    cat tmp-inward >> tmp-inward-all
done < list

nLines=`wc -l tmp-inward-all`

# DATETIME=`date +%Y%m%d_%H%M%S`
#DATETIME=`date +%Y%m%d`
time CUDA_VISIBLE_DEVICES=0 ./9-inward tmp-inward-all $nLines
cp tmp-inward msec-inward-${DATE}
cp raw-inward raw-inward-${DATE}

scp msec-inward-${DATE} 192.168.72.6:/mnt/sdc/splunk-session-directed/inward/gpu02/
scp msec-inward-${DATE} 192.168.72.6:/mnt/sdc/splunk-session-directed/inward/gpu02/current
scp raw-inward-${DATE} 192.168.72.6:/mnt/sdc/splunk-session-directed/inward/gpu02/raw/

mv msec-inward-${DATE} ./backup
mv raw-inward-${DATE} ./backup

#######

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

rm -rf tmp-outward-all
touch tmp-outward-all

ls x* > list
while read line; do
    echo $line
    nLines=`wc -l $line | cut -d " " -f 1`
    echo $nLines
    CUDA_VISIBLE_DEVICES=0 ./8-outward $line $nLines
    cat tmp-outward >> tmp-outward-all
done < list

nLines=`wc -l tmp-outward-all | cut -d " " -f 1`
echo $nLines

# DATETIME=`date +%Y%m%d_%H%M%S`
#DATETIME=`date +%Y%m%d`
time CUDA_VISIBLE_DEVICES=0 ./9-outward tmp-outward-all $nLines
cp tmp-outward msec-outward-${DATE}
cp raw-outward raw-outward-${DATE}

scp msec-outward-${DATE} 192.168.72.6:/mnt/sdc/splunk-session-directed/outward/gpu02/
scp msec-outward-${DATE} 192.168.72.6:/mnt/sdc/splunk-session-directed/outward/gpu02/current
scp raw-outward-${DATE} 192.168.72.6:/mnt/sdc/splunk-session-directed/outward/gpu02/raw/

mv msec-outward-${DATE} ./backup
mv raw-outward-${DATE} ./backup
