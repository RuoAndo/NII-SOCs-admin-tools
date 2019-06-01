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

# copy
cp tmp-twitter tmp-twitter-${DATE}
cp tmp-ssl tmp-ssl-${DATE}
cp tmp-web-browsing tmp-web-browsing-${DATE}
cp tmp-google-play tmp-google-play-${DATE}
cp tmp-web-crawler tmp-web-crawler-${DATE}

# 
scp tmp-twitter-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_application_by_gpu/gpu04/
scp tmp-ssl-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_application_by_gpu/gpu04/
scp tmp-web-browsing-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_application_by_gpu/gpu04/
scp tmp-google-play-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_application_by_gpu/gpu04/
scp tmp-web-crawler-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_application_by_gpu/gpu04/

# current
scp tmp-twitter-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_application_by_gpu/gpu04/tmp-twitter-current
scp tmp-ssl-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_application_by_gpu/gpu04/tmp-ssl-current
scp tmp-web-browsing-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_application_by_gpu/gpu04/tmp-web-browsing-current
scp tmp-google-play-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_application_by_gpu/gpu04/tmp-google-play-current
scp tmp-web-crawler-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_application_by_gpu/gpu04/tmp-web-crawler-current

rm -rf ${DATE}
rm -rf tmp-twitter-${DATE}
rm -rf tmp-ssl-${DATE}
rm -rf tmp-web-browsing-${DATE}
rm -rf tmp-google-play-${DATE}
rm -rf tmp-web-crawler-${DATE}
