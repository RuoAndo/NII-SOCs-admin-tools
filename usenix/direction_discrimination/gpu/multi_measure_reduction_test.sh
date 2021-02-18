date=$(date -d '3 day ago' "+%Y%m%d")
echo $date
REGION_NAME=$1

./build_cpu_reduction.sh cpu_reduction
./cpu_reduction ./ingress_${REGION_NAME}_${date}
cp tmp-counts ./ingress_${REGION_NAME}/${date}


