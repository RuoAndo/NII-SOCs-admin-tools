#!/bin/sh

date8=`date --date '8 day ago' +%Y%m%d`
date7=`date --date '7 day ago' +%Y%m%d`
date6=`date --date '6 day ago' +%Y%m%d`
date5=`date --date '5 day ago' +%Y%m%d`
date4=`date --date '4 day ago' +%Y%m%d`
date3=`date --date '3 day ago' +%Y%m%d`
date2=`date --date '2 day ago' +%Y%m%d`
date1=`date --date '1 day ago' +%Y%m%d`

rm -rf list
touch list

tree -d | grep 201 | cut -d " " -f2 > list0
#cat list0

grep $date8 list0 >> list
grep $date7 list0 >> list
grep $date6 list0 >> list
grep $date5 list0 >> list
grep $date4 list0 >> list
grep $date3 list0 >> list
grep $date2 list0 >> list
grep $date1 list0 >> list

cat list

