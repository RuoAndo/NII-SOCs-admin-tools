date=`date --date '1 day ago' +%Y%m%d`
scp -r ${date}_0 192.168.72.3:/data1/
