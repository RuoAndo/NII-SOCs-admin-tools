if [ "$1" = "" ]
then
    echo "./do.sh IPADDR"
    exit 1
fi

nLines=300000000
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

WHOLE_LINE=`wc -l all-whole | cut -d " " -f 1`
echo $WHOLE_LINE

div=`echo $(($WHOLE_LINE / $nLines))`
echo "div:"$div

LINES_TO_PROCESS=`echo $(($nLines * $div))`
echo "lines to process:"$LINES_TO_PROCESS

head -n $LINES_TO_PROCESS all-whole > all-org-cut

./build-gpu.sh group10
echo "now spliting..."

rm -rf x*
split -l $nLines all-org-cut

ls xa* > list

rm -rf result-all
touch result-all

while read line; do
    echo $line
    split -d -l 10000000 $line
    CUDA_VISIBLE_DEVICES=1 ./group10 $1 $nLines
    \cp result result.${line}
    cat result >> result-all
done < list

wc -l all-org-cut
