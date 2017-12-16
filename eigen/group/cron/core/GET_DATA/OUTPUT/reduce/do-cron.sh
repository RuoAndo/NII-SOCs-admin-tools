date=`date --date '2 day ago' +%Y%m%d`
/mnt/sdc/GET_DATA/OUTPUT/reduce/do-list.sh iplist /mnt/sdc/GET_DATA/OUTPUT/$date reduce-daily
cp iplist traversed/iplist-$date
