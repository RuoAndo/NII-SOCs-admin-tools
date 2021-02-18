date=$(date -d '2 day ago' "+%Y%m%d")
echo $date
REGION_NAME=$1

if [ "$1" = "" ]
then
    echo "usage: ./multi_measure.sh [REGION_NAME]"
    exit 1
fi

start_time=`date +%s`

mkdir ingress_${REGION_NAME}
mkdir egress_${REGION_NAME}

mkdir ingress_${REGION_NAME}_${date}
mkdir egress_${REGION_NAME}_${date}

#mkdir ingress
#mkdir egress

./build.sh multi_measure

BASEDIR="/mnt/data2/"

du -h ${BASEDIR}${date}

echo "copying..."
time cp -r ${BASEDIR}${date} .
time ./multi_measure $date list-${REGION_NAME}

ls ./${date}/*ingress > list

while read line; do
    fn_src=`echo $line`
    fn_dst=`echo $line | cut -d "/" -f 3`
    cat header > tmp
    cat ${fn_src} >> tmp
    #echo "./ingress_${REGION_NAME}/${REGION_NAME}_${fn_dst}_${date}"
    cp tmp ./ingress_${REGION_NAME}_${date}/${REGION_NAME}_${fn_dst}_${date}
    mv tmp ./ingress_${REGION_NAME}/${REGION_NAME}_${fn_dst}_${date}
done < list

ls ./${date}/*egress > list

while read line; do
    fn_src=`echo $line`
    fn_dst=`echo $line | cut -d "/" -f 3`
    cat header > tmp
    cat ${fn_src} >> tmp
    #echo "./egress_${REGION_NAME}/${REGION_NAME}_${fn_dst}_${date}"
    cp tmp ./egress_${REGION_NAME}_${date}/${REGION_NAME}_${fn_dst}_${date}
    mv tmp ./egress_${REGION_NAME}/${REGION_NAME}_${fn_dst}_${date}
done < list

rm -rf ${date}

end_time=`date +%s`
run_time=$((end_time - start_time))
run_time_minutes=`echo $(( ${run_time} / 60))`

echo "ELAPSED TIME:"${date}":"$run_time":"$run_time_minutes

du -h ${BASEDIR}${date}

date=$(date -d '10 day ago' "+%Y%m%d")
rm -rf ./egress_${REGION_NAME}/${REGION_NAME}*${date}
rm -rf ./ingress_${REGION_NAME}/${REGION_NAME}*${date}
