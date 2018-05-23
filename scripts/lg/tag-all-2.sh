if [ "$1" = "" ]
then
    echo "no argument: ./tag-all-2.sh startDate endDate TAG"
fi

ls *detailed* | grep iplist | grep "h-" > tmp-detailed-all

START_DATE=$1
END_DATE=$2
TAG=$3

rm -rf tmp-detailed-list
touch tmp-detailed-list

for (( DATE=${START_DATE} ; ${DATE} < ${END_DATE} ; DATE=`date -d "${DATE} 1 day" '+%Y%m%d'` )) ; do
  echo ${DATE}
  grep $DATE tmp-detailed-all >> tmp-detailed-list
done

rm -rf tmp-tag-all
touch tmp-tag-all

while read line; do
    echo $line
    python readjson3.py $line $TAG | tee -a tmp-tag-all
done < tmp-detailed-list
