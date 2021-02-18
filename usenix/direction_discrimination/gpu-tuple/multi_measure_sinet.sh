date=$(date -d '1 day ago' "+%Y%m%d")
echo $date
REGION_NAME="sinet"

mkdir sinet_ingress_${date}
mkdir sinet_egress_${date}

mkdir sinet_ingress
mkdir sinet_egress

./build-traverse.sh discernGPU

echo "copying..."
time cp -r /mnt/data/${date} .
time ./discernGPU $date list-${REGION_NAME}

ls ./${date}/*ingress > list

while read line; do
    fn_src=`echo $line`
    fn_dst=`echo $line | cut -d "/" -f 3`
    cat header > tmp
    cat ${fn_src} >> tmp
    echo "./sinet_ingress_${date}/${REGION_NAME}_${fn_dst}_${date}"
    cp tmp ./sinet_ingress_${date}/${REGION_NAME}_${fn_dst}_${date}
    mv tmp ./sinet_ingress/${REGION_NAME}_${fn_dst}_${date}
done < list

ls ./${date}/*egress > list

while read line; do
    fn_src=`echo $line`
    fn_dst=`echo $line | cut -d "/" -f 3`
    cat header > tmp
    cat ${fn_src} >> tmp
    echo "./sinet_egress_${date}/${REGION_NAME}_${fn_dst}_${date}"
    cp tmp ./sinet_egress_${date}/${REGION_NAME}_${fn_dst}_${date}
    mv tmp ./sinet_egress/${REGION_NAME}_${fn_dst}_${date}
done < list

rm -rf ${date}
