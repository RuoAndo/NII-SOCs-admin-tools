#if [ "$1" = "" ]
#then
#    echo "usage: ./repeat [FILE_NAME]"
#    exit 1
#fi

DATE=`date --date '4 day ago' +%Y%m%d` 
echo $DATE

ls -alh /data1/${DATE}/all-org
echo "copying..."
cp /data1/${DATE}/all-org .

nLines=`wc -l all-org | cut -d " " -f 1`
LINES_TO_SPLIT=`expr $nLines / 50`

echo ${LINES_TO_SPLIT} 

rm -rf *_ingress
rm -rf *_egress

echo "removing and splitting..."
rm -rf x*
split -l ${LINES_TO_SPLIT} -a 2 all-org x

ls x* > list

./build.sh netmask8

SECONDS=0
while read line; do
    echo $line
    comstr="./netmask8 us-east-1 ${line} ${LINES_TO_SPLIT} &"
    echo $comstr
    eval $comstr
done < list

wait

time=$SECONDS
echo $time" sec"

### cat all (ingress)
 
ls *_ingress > list_ingress

rm -rf all_ingress
touch all_ingress

SECONDS=0

while read line; do
    #echo "writing"$line"..."
    cat $line >> all_ingress
done < list_ingress

time=$SECONDS
echo $time" sec"

### cat all (egress)

ls *_egress > list_egress

rm -rf all_egress
touch all_egress

rm -rf all_ingress
touch all_ingress

SECONDS=0

while read line; do
    #echo "writing "$line"..."
    cat $line >> all_egress
done < list_egress

while read line; do
    #echo "writing "$line"..."
    cat $line >> all_ingress
done < list_ingress

time=$SECONDS
echo $time" sec"

wc -l all_egress
wc -l all_ingress

rm -rf x*
