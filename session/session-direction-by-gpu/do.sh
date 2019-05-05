DATE=`date --date '3 day ago' +%Y%m%d`
echo $DATE

./build-traverse.sh traverse4

mkdir $DATE
echo "copying..."
time cp /root/${DATE}/all-org ./${DATE}/
cd ${DATE}

echo "spliting files..."
time split -l 5000000 all-org
rm -rf all-org
cd ..
time CUDA_VISIBLE_DEVICES=0 ./traverse4 ./${DATE}
cp tmp-inward tmp-inward-${DATE}
cp tmp-outward tmp-outward-${DATE}

scp tmp-inward-${DATE} 192.168.72.6:/mnt/sdc/splunk-session-direction-by-gpu/
scp tmp-outward-${DATE} 192.168.72.6:/mnt/sdc/splunk-session-direction-by-gpu/

scp tmp-inward-${DATE} 192.168.72.6:/mnt/sdc/splunk-session-direction-by-gpu/tmp-inward-current
scp tmp-outward-${DATE} 192.168.72.6:/mnt/sdc/splunk-session-direction-by-gpu/tmp-outward-current

rm -rf ${DATE}
rm -rf tmp-inward-${DATE}
rm -rf tmp-outward-${DATE} 
