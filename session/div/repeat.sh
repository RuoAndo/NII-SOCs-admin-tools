START_DATE=`date --date '5 day ago' +%Y%m%d`
END_DATE=`date --date '2 day ago' +%Y%m%d`

echo $START_DATE
echo $END_DATE

rm -rf all-whole
touch all-whole

for (( DATE=${START_DATE} ; ${DATE} < ${END_DATE} ; DATE=`date -d "${DATE} 1 day" '+%Y%m%d'` )) ; do
    echo ${DATE}
    cat /mnt/data2/${DATE}/all-org >> all-whole
done

wc -l all-whole
