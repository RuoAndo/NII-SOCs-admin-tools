if [ "$1" = "" ]
then
    echo "no argument ./cat2.sh [A/T/C]"
    exit 
fi

ls $1* > list

rm -rf all-$1
touch all-$1

START_DATE=`date --date '8 day ago' +%Y%m%d`
END_DATE=`date --date '1 day ago' +%Y%m%d`

cat HEADER/$1.csv > all-$1

for (( DATE=${START_DATE} ; ${DATE} <= ${END_DATE} ; DATE=`date -d "${DATE} 1 day" '+%Y%m%d'` )) ; do
  gr=`grep ${DATE} list`
  echo $gr
  cat $gr >> all-$1
done

#cat HEADER/$1.csv > all-$1
#while read line; do
#    echo $line
#    cat $line >> all-$1
#done < list

