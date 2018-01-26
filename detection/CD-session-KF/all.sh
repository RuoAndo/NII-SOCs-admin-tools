year=`date --date '8 day ago' +%Y`
month=`date --date '8 day ago' +%m`
day=`date --date '8 day ago' +%d`

echo $year $month $day

time ./makelist.sh > list
time ./do-gendata.sh list instIDlist  
time ./auto.sh instIDlist $year $month $day
