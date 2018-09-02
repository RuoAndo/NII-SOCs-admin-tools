START_DATE=$1
END_DATE=$2

rm -rf all-destIP_bytes
touch all-destIP_bytes

rm -rf all-sourceIP_bytes
touch all-sourceIP_bytes

echo "timestamp, IP, counted, bytes, sent, recv" >> all-destIP_bytes
echo "timestamp, IP, counted, bytes, sent, recv" >> all-sourceIP_bytes

for (( DATE=${START_DATE} ; ${DATE} <= ${END_DATE} ; DATE=`date -d "${DATE} 1 day" '+%Y%m%d'` )) ; do

  echo ${DATE}

  cp add-date-ipBytes.py ${DATE}

  cd ${DATE}

  python add-date-ipBytes.py destIP_bytes ${DATE} >> ../all-destIP_bytes
  python add-date-ipBytes.py sourceIP_bytes ${DATE} >> ../all-sourceIP_bytes

  cd ..
done

scp all-destIP_bytes 192.168.72.5:splunk-session-ipBytes/
scp all-sourceIP_bytes 192.168.72.5:splunk-session-ipBytes/
