date=`date --date '3 day ago' +%Y%m%d`

cat ${date}_0/reduced_all-${date} > reduced_all_${date} 
cat ${date}_1/reduced_all-${date} >> reduced_all_${date} 
cat ${date}_2/reduced_all-${date} >> reduced_all_${date} 

