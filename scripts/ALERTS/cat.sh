ls $1* > list

rm -rf all-$1
touch all-$1

#START_DATE="20140101"
#END_DATE="20140403"
#for (( DATE=${START_DATE} ; ${DATE} < ${END_DATE} ; DATE=`date -d "${DATE} 1 day" '+%Y%m%d'` )) ; do
#  echo ${DATE}
#done

cat HEADER/$1.csv > all-$1

while read line; do
    echo $line
    cat $line >> all-$1
done < list

