date8=`date --date '8 day ago' +%Y%m%d`
date7=`date --date '7 day ago' +%Y%m%d`
date6=`date --date '6 day ago' +%Y%m%d`
date5=`date --date '5 day ago' +%Y%m%d`
date4=`date --date '4 day ago' +%Y%m%d`
date3=`date --date '3 day ago' +%Y%m%d`
date2=`date --date '2 day ago' +%Y%m%d`
date1=`date --date '1 day ago' +%Y%m%d`

\cp -r /data1/count-session/$date8 .
\cp -r /data1/count-session/$date7 .
\cp -r /data1/count-session/$date6 .
\cp -r /data1/count-session/$date5 .
\cp -r /data1/count-session/$date4 .
\cp -r /data1/count-session/$date3 .
\cp -r /data1/count-session/$date2 .
\cp -r /data1/count-session/$date1 .

echo $date8
echo $date7
echo $date6
echo $date5
echo $date4
echo $date3
echo $date2
echo $date1
