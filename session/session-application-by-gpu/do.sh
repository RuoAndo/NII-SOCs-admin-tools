DATE=`date --date '3 day ago' +%Y%m%d`
echo $DATE

./build-traverse.sh traverse6

mkdir $DATE
echo "copying..."
time cp /root/${DATE}/all-org ./${DATE}/
cd ${DATE}

echo "spliting files..."
time split -l 5000000 all-org
rm -rf all-org
cd ..
time CUDA_VISIBLE_DEVICES=1 ./traverse6 ./${DATE}
cp tmp-twitter tmp-twitter-${DATE}
cp tmp-ssl tmp-ssl-${DATE}
cp tmp-web-browsing tmp-web-browsing-${DATE}

scp tmp-twitter-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_application_by_gpu/gpu02/
scp tmp-ssl-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_application_by_gpu/gpu02/
scp tmp-web-browsing-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_application_by_gpu/gpu02/

scp tmp-twitter-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_application_by_gpu/gpu02/tmp-twitter-current
scp tmp-ssl-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_application_by_gpu/gpu02/tmp-ssl-current
scp tmp-web-browsing-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_application_by_gpu/gpu02/tmp-web-browsing-current

rm -rf ${DATE}
rm -rf tmp-twitter-${DATE}
rm -rf tmp-ssl-${DATE}
rm -rf tmp-web-browsing-${DATE}
