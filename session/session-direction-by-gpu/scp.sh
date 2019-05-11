DATE=`date --date '4 day ago' +%Y%m%d`
echo $DATE

scp tmp-inward-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_direction_by_gpu/gpu02/
scp tmp-outward-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_direction_by_gpu/gpu02/

scp tmp-inward-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_direction_by_gpu/gpu02/tmp-inward-current
scp tmp-outward-${DATE} 192.168.72.6:/mnt/sdc/splunk_session_direction_by_gpu/gpu02/tmp-outward-current
