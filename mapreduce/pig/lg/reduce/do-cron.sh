date=`date --date '2 day ago' +%Y%m%d`
#echo $date
./do-list.sh iplist /mnt/sdc/GET_DATA/OUTPUT/$date reduce-daily
