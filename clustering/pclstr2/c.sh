date=`date --date '2 day ago' +%Y%m%d`
echo $date

today=$(date "+%Y%m%d")
hostname=`hostname`

python count-percent.py count-result > count-percent-$hostname-$today
tail count-percent-$hostname-$today
time python count-grep.py count-result result-all > iplist-$hostname-$today

wl=`wc -l $1 | cut -d " " -f 1`
\cp iplist-$hostname-$today iplist-$hostname-$today-all-${date}-${allnLines}
tail iplist-$hostname-$today-all-${date}-${allnLines}

scp iplist-$hostname-$today-all-${date}-${allnLines} 192.168.72.5:/mnt/sdc/es/batch/iplist/

