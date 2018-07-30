ls *ip_detailed_data.txt > list-tmp

rm -rf /mnt/sdc/splunk-lg/newip/all 
touch /mnt/sdc/splunk-lg/newip/all 

#echo "timestamp, ipaddr, tag" >> /mnt/sdc/iplist-new-lg/all 
echo "timestamp, ipaddr, tag" >> /mnt/sdc/splunk-lg/newip/all 
while read line; do
    echo $line
    #python readjson.py $line >> /mnt/sdc/iplist-new-lg/all 
    python readjson.py $line >> /mnt/sdc/splunk-lg/newip/all 
done < list-tmp
