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
cp tmp-social-networking tmp-social-networking-${DATE}

#scp tmp-social-networking-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_application_by_gpu/gpu04/

#rm -rf ${DATE}
#rm -rf tmp-social-networking-${DATE}
