DATE=`date --date '4 day ago' +%Y%m%d`
echo $DATE

./build-traverse.sh traverse6

mkdir $DATE
echo "copying..."
time cp /mnt/data2/${DATE}/all-org ./${DATE}/
cd ${DATE}

echo "spliting files..."
time split -l 5000000 all-org
rm -rf all-org
cd ..
time CUDA_VISIBLE_DEVICES=1 ./traverse6 ./${DATE}
cp tmp-cn-inward tmp-cn-inward-${DATE}
cp tmp-cn-outward tmp-cn-outward-${DATE}

scp tmp-cn-inward-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_country_by_gpu/gpu04/
scp tmp-cn-inward-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_country_by_gpu/gpu04/tmp-cn-inward-current
scp tmp-cn-outward-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_country_by_gpu/gpu04/
scp tmp-cn-outward-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_country_by_gpu/gpu04/tmp-cn-outward-current

rm -rf ${DATE}
rm -rf tmp-cn-inward-${DATE}
rm -rf tmp-cn-outward-${DATE}

