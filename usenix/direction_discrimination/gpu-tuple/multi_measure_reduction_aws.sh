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

./build-traverse.sh discernGPU

BASEDIR="/root/"

du -h ${BASEDIR}${date}

echo "copying..."
time cp -r ${BASEDIR}${date} .
time ./discernGPU $date list-${REGION_NAME}

ls ./${date}/*ingress > list

while read line; do
    fn_src=`echo $line`
    fn_dst=`echo $line | cut -d "/" -f 3`
    cat header > tmp
    cat ${fn_src} >> tmp
    echo "./ingress_${REGION_NAME}/${REGION_NAME}_${fn_dst}_${date}"
    cp tmp ./ingress_${REGION_NAME}_${date}/${REGION_NAME}_${fn_dst}_${date}
    mv tmp ./ingress_${REGION_NAME}/${REGION_NAME}_${fn_dst}_${date}
done < list

ls ./${date}/*egress > list

while read line; do
    fn_src=`echo $line`
    fn_dst=`echo $line | cut -d "/" -f 3`
    cat header > tmp
    cat ${fn_src} >> tmp
    echo "./egress_${REGION_NAME}/${REGION_NAME}_${fn_dst}_${date}"
    cp tmp ./egress_${REGION_NAME}_${date}/${REGION_NAME}_${fn_dst}_${date}
    mv tmp ./egress_${REGION_NAME}/${REGION_NAME}_${fn_dst}_${date}
done < list

rm -rf ${date}

./build_cpu_reduction.sh cpu_reduction

mkdir histo_ingress_${REGION_NAME}
mkdir histo_egress_${REGION_NAME}

start_time=`date +%s`
rm -rf tmp-counts
rm -rf tmp
./cpu_reduction ./ingress_${REGION_NAME}_${date}
cat header-histo > tmp
cat tmp-counts >> tmp 
mv tmp ./histo_ingress_${REGION_NAME}/${date}

rm -rf tmp-counts
rm -rf tmp
./cpu_reduction ./egress_${REGION_NAME}_${date}
cat header-histo > tmp
cat tmp-counts >> tmp 
mv tmp ./histo_egress_${REGION_NAME}/${date}

##
scp ingress_${REGION_NAME}_${date}/* 192.168.76.216:/mnt/data/aws/ingress/
scp egress_${REGION_NAME}_${date}/* 192.168.76.216:/mnt/data/aws/egress/  

scp -r ingress_${REGION_NAME}_${date} 192.168.76.216:/mnt/data/aws/${REGION_NAME}/
scp -r egress_${REGION_NAME}_${date} 192.168.76.216:/mnt/data/aws/${REGION_NAME}/

end_time=`date +%s`
run_time=$((end_time - start_time))
run_time_minutes=`echo $(( ${run_time} / 60))`

du -h ${BASEDIR}${date}

echo "ELAPSED TIME:"${date}":"$run_time":"$run_time_minutes

date=$(date -d '90 day ago' "+%Y%m%d")
rm -rf ./egress_${REGION_NAME}/${REGION_NAME}*${date}
rm -rf ./ingress_${REGION_NAME}/${REGION_NAME}*${date}

rm -rf ./egress_${REGION_NAME}_${date}
rm -rf ./ingress_${REGION_NAME}_${date}

rm -rf ./histo_egress_${REGION_NAME}/${date}
rm -rf ./histo_ingress_${REGION_NAME}/${date}

