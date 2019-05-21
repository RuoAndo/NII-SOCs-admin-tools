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
cp tmp-web-advertisements tmp-web-advertisements-${DATE}
cp tmp-online-storage-and-backup tmp-online-storage-and-backup-${DATE}
cp tmp-content-delivery-networks tmp-content-delivery-networks-${DATE}

scp tmp-social-networking-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_category_by_gpu/gpu04/
scp tmp-social-networking-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_category_by_gpu/gpu04/tmp-social-networking-current
scp tmp-online-storage-and-backup-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_category_by_gpu/gpu04/tmp-online-storage-and-backup-current
scp tmp-content-delivery-networks-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_category_by_gpu/gpu04/tmp-content-delivery-networks-current

scp tmp-social-networking-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_category_by_gpu/gpu04/
scp tmp-web-advertisements-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_category_by_gpu/gpu04/
scp tmp-online-storage-and-backup-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_category_by_gpu/gpu04/
scp tmp-content-delivery-networks-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_category_by_gpu/gpu04/

rm -rf ${DATE}
rm -rf tmp-social-networking-${DATE}
rm -rf tmp-web-advertisements-${DATE}
rm -rf tmp-online-storage-and-backup-${DATE}
rm -rf tmp-content-delivery-networks-${DATE}
