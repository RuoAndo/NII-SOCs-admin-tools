if [ "$1" = "" ]
then
    echo "./do.sh IPADDR"
    exit 1
fi

nLines=300000000
START_DATE=`date --date '6 day ago' +%Y%m%d`
END_DATE=`date --date '2 day ago' +%Y%m%d`

echo "start date:"$START_DATE
echo "end date:"$END_DATE

rm -rf all-whole
touch all-whole

echo "#1 concatenating files..."
start_time=`date +%s`

for (( DATE=${START_DATE} ; ${DATE} < ${END_DATE} ; DATE=`date -d "${DATE} 1 day" '+%Y%m%d'` )) ; do
    echo ${DATE}
    cat /mnt/data/${DATE}/all-org >> all-whole
done

end_time=`date +%s`
time=$((end_time - start_time))
echo "done."$time

WHOLE_LINE=`wc -l all-whole | cut -d " " -f 1`
echo $WHOLE_LINE

div=`echo $(($WHOLE_LINE / $nLines))`
echo "div:"$div

LINES_TO_PROCESS=`echo $(($nLines * $div))`
echo "lines to process:"$LINES_TO_PROCESS

echo "#2 cutting files..."
start_time=`date +%s`

head -n $LINES_TO_PROCESS all-whole > all-org-cut

end_time=`date +%s`
time=$((end_time - start_time))
echo "done."$time

./build-gpu.sh group12
echo "now spliting..."

rm -rf x*
split -l $nLines all-org-cut

ls xa* > list

rm -rf result-all
touch result-all

echo "#3 entering main loop..."
start_time=`date +%s`

# 30 threads (300000000 = 10000000 * 30)
while read line; do
    echo $line
    split -d -l 10000000 $line
    CUDA_VISIBLE_DEVICES=0 ./group12 $1 $nLines
    \cp result result.${line}
    cat result >> result-all
done < list

end_time=`date +%s`
time=$((end_time - start_time))
echo "done."$time

wc -l all-org-cut
