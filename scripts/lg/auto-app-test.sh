date=`date --date "2 days ago" +%Y%m%d`
#ls -lt iplist/* | grep app > list
ls iplist/* | grep app > list
#dn=`tail -n 1 list` #| cut -d "/" -f 2
dn=`grep $date list | cut -d "/" -f 2`
echo $dn
