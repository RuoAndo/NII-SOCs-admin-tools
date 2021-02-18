date=$(date -d '2 day ago' "+%Y%m%d")
echo $date
REGION_NAME=$1

if [ "$1" = "" ]
then
    echo "usage: ./multi_measure.sh [REGION_NAME]"
    exit 1
fi

mkdir ingress
mkdir egress

#mkdir ingress_${date}
#mkdir egress_${date}

./build.sh multi_measure

echo "copying..."
time cp -r /mnt/data/${date} .
time ./multi_measure $date list-${REGION_NAME}

ls ./${date}/*ingress > list

while read line; do
    fn_src=`echo $line`
    fn_dst=`echo $line | cut -d "/" -f 3`
    cat header > tmp
    cat ${fn_src} >> tmp
    echo "./ingress/${REGION_NAME}_${fn_dst}_${date}"
    #cp tmp ./ingress_${date}/${REGION_NAME}_${fn_dst}_${date}
    mv tmp ./ingress/${REGION_NAME}_${fn_dst}_${date}
done < list

ls ./${date}/*egress > list

while read line; do
    fn_src=`echo $line`
    fn_dst=`echo $line | cut -d "/" -f 3`
    cat header > tmp
    cat ${fn_src} >> tmp
    echo "./egress/${REGION_NAME}_${fn_dst}_${date}"
    #cp tmp ./egress_${date}/${REGION_NAME}_${fn_dst}_${date}
    mv tmp ./egress/${REGION_NAME}_${fn_dst}_${date}
done < list

rm -rf ${date}
