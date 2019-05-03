DATE=`date --date '2 day ago' +%Y%m%d`
echo $DATE

mkdir $DATE
time cp /mnt/data2/${DATE}/all-org ./${DATE}/
cd ${DATE}
time split -l 5000000 all-org
rm -rf all-org
cd ..
time ./traverse4 ./${DATE}
cp tmp-inward tmp-inward-${DATE}
cp tmp-outward tmp-outward-${DATE}

scp 192.168.72.6:/mnt/sdc/splunk-session-direction-by-gpu/tmp-inward-${DATE}
scp 192.168.72.6:/mnt/sdc/splunk-session-direction-by-gpu/tmp-outward-${DATE}
