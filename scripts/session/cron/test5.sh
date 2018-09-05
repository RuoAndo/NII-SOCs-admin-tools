START_DATE=`date --date '4 day ago' +%Y%m%d`
END_DATE=`date --date '4 day ago' +%Y%m%d`

nLines=`wc -l all-dest_port | cut -d " " -f 1`
./build.sh count_destPort_final 
./count_destPort_final all-dest_port $nLines
cp destPort_final destPort_final-${START_DATE}-${END_DATE}
scp destPort_final-${START_DATE}-${END_DATE} 192.168.72.5:/mnt/sdc/splunk-session/$1

nLines=`wc -l all-source_port | cut -d " " -f 1`
./build.sh count_sourcePort_final
./count_sourcePort_final all-source_port $nLines
cp sourcePort_final sourcePort_final-${START_DATE}-${END_DATE}
scp sourcePort_final-${START_DATE}-${END_DATE} 192.168.72.5:/mnt/sdc/splunk-session/$1
