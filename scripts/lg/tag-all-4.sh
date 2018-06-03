if [ "$1" = "" ]
then
    echo "no argument: ./tag-all-2.sh startDate endDate TAG"
fi

###################

ls *detailed* | grep iplist | grep "h-" > tmp-detailed-all

START_DATE=$1
END_DATE=$2
TAG=$3

rm -rf tmp-detailed-list
touch tmp-detailed-list

for (( DATE=${START_DATE} ; ${DATE} <= ${END_DATE} ; DATE=`date -d "${DATE} 1 day" '+%Y%m%d'` )) ; do
  #echo ${DATE}
  grep $DATE tmp-detailed-all | grep -v cut >> tmp-detailed-list
done

####################

#delta/delta-sorted-20180522_ip_detailed_data.txt                                                                        
ls *detailed* | grep delta > tmp-delta-list

rm -rf tmp-delta-all
touch tmp-delta-all

for (( DATE=${START_DATE} ; ${DATE} <= ${END_DATE} ; DATE=`date -d "${DATE} 1 day" '+%Y%m%d'` )) ; do
  #echo ${DATE}
  grep $DATE tmp-delta-list >> tmp-delta-all
done

####################

rm -rf tmp-tag-all
touch tmp-tag-all

# iplist-h-app07-20180516-all-154255819_ip_detailed_data.txt

while read line; do
    #echo $line
    python readjson3.py $line $TAG | tee -a tmp-tag-all
done < tmp-detailed-list

####

# delta-sorted-20180516_ip_detailed_data.txt

while read line; do
    #echo $line
    python readjson-delta.py $line $TAG | tee -a tmp-tag-all
done < tmp-delta-all

echo "##### ##### #####"
echo "##### ##### #####"
echo "##### ##### #####"

python trans-date-splunk.py tmp-tag-all > /mnt/sdc/lg_splunk


