date=`date --date '1 day ago' +%Y%m%d`
scp -r ${date}_1 192.168.72.4:/data1/
