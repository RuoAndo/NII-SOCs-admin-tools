date=`date --date '2 day ago' +%Y%m%d`
scp -r ${date} 192.168.72.6:/mnt/sdd/
scp -r ${date}_0 192.168.72.6:/mnt/sdd/
scp -r ${date}_1 192.168.72.6:/mnt/sdd/
scp -r ${date}_2 192.168.72.6:/mnt/sdd/
sleep 1

scp -r ${date} 192.168.72.3:/data1/
scp -r ${date}_0 192.168.72.3:/data1/
scp -r ${date}_1 192.168.72.3:/data1/
scp -r ${date}_2 192.168.72.3:/data1/
sleep 1

scp -r ${date} 192.168.72.4:/data1/
scp -r ${date}_0 192.168.72.4:/data1/
scp -r ${date}_1 192.168.72.4:/data1/
scp -r ${date}_2 192.168.72.4:/data1/
sleep 1
