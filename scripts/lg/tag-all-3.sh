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

# iplist-h-app07-20180516-all-154255819_ip_detailed_data.txt
#while read line; do
    #echo $line
#    python readjson4.py $line $TAG | tee -a tmp-tag-all
#done < tmp-detailed-list

echo "##### ##### #####"
echo "##### ##### #####"
echo "##### ##### #####"

./sort-tag.pl tmp-tag-all > tmp-tag-all-sorted
cat tmp-tag-all-sorted

python trans-date-splunk.py tmp-tag-all-sorted | grep -v AIS > tmp-tag-all-sorted-splunk-$1-$2-$3
#echo "_time, ipaddr, tagname" > tmp-tag-all-sorted-splunk-$1-$2-$3
#cat tmp-tag-all-sorted | grep -v AIS >> tmp-tag-all-sorted-splunk-$1-$2-$3
cp tmp-tag-all-sorted-splunk-$1-$2-$3 /mnt/sdc/lg_splunk

cat tmp-tag-all | awk -F ',' '{print $2}' > tmp-iplist
./drem.pl tmp-iplist > tmp-iplist-drem

nWc=`wc -l tmp-iplist-drem | cut -d " " -f 1`
nTag=`wc -l tmp-tag-all | cut -d " " -f 1`

echo "tags:"$nTag
echo "IPs:"$nWc
cat tmp-iplist-drem | tee result
