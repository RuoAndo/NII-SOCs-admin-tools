date=`date --date '1 day ago' +%Y%m%d`
scp -r ${date}_0 192.168.72.6:/mnt/sdd/
scp -r ${date}_1 192.168.72.6:/mnt/sdd/
scp -r ${date}_2 192.168.72.6:/mnt/sdd/

date2=`date --date '1 day ago' +%Y%m%d`
scp SESSION_${date}_0000-${date2}_0000.csv 192.168.72.6:/mnt/sdd

date3=`date --date '10 day ago' +%Y%m%d`
date4=`date --date '9 day ago' +%Y%m%d`
rm -rf SESSION_${date3}_0000-${date4}_0000.csv 
rm -rf ${date3}
rm -rf ${date3}_0
rm -rf ${date3}_1
rm -rf ${date3}_2
