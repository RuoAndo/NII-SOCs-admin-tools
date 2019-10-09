if [ "$1" = "" ]
then
    echo "usage: ./repeat [FILE_NAME]"
    exit 1
fi

nLines=`wc -l $1 | cut -d " " -f 1`
LINES_TO_SPLIT=`expr $nLines / 50`

echo ${LINES_TO_SPLIT} 

rm -rf *_ingress
rm -rf *_egress

rm -rf x*
split -l ${LINES_TO_SPLIT} -a 2 $1 x

ls x* > list

SECONDS=0
while read line; do
    echo $line
    comstr="./netmask8 amazon_list ${line} ${LINES_TO_SPLIT} &"
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

SECONDS=0

while read line; do
    #echo "writing "$line"..."
    cat $line >> all_egress
done < list_egress

time=$SECONDS
echo $time" sec"

wc -l all_egress
wc -l all_ingress

rm -rf x*
