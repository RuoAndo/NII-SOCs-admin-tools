#2018/06/30 00:00:00,45.55.13.94,[DSHIELD] Top 5000 Attackers
#2018/07/02 00:00:00,80.82.77.139,[AIS] AIS Intel Report, NCCIC:STIX_Package-bdff3a53-1237-495f-a222-edf30161411f

ls *detailed* > list-tmp

rm -rf /mnt/sdc/splunk-lg/delta/all
touch /mnt/sdc/splunk-lg/delta/all

rm -rf all
touch all

while read line; do
    echo $line
    echo "timestamp; ipaddr; tag" >> /mnt/sdc/splunk-lg/delta/all 
    python readjson-semicolon.py $line >> /mnt/sdc/splunk-lg/delta/all
done < list-tmp

while read line; do
    echo $line
    echo "timestamp, ipaddr, tag" >> all 
    python readjson.py $line >> all
done < list-tmp

rm -rf list-tmp
