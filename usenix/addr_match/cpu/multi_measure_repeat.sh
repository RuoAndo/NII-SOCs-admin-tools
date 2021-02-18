#date=$(date -d '13 day ago' "+%Y%m%d")

STARTDATE=20200524
ENDDATE=20200606

date=$STARTDATE
while [ 1 ] ; do

   echo $date
   REGION_NAME=$1

   if [ "$1" = "" ]
   then
       echo "usage: ./multi_measure_repeat.sh [REGION_NAME]"
       exit 1
   fi

   start_time=`date +%s`

   mkdir ingress_${REGION_NAME}
   mkdir egress_${REGION_NAME}

   mkdir ingress_${REGION_NAME}_${date}
   mkdir egress_${REGION_NAME}_${date}

   ./build.sh multi_measure

   echo "copying..."
   time cp -r /root/${date} .
   time ./multi_measure $date list-${REGION_NAME}

   ls ./${date}/*ingress > list

   while read line; do
       fn_src=`echo $line`
       fn_dst=`echo $line | cut -d "/" -f 3`
       cat header > tmp
       cat ${fn_src} >> tmp
       echo "./ingress/${REGION_NAME}_${fn_dst}_${date}"
       cp tmp ./ingress_${REGION_NAME}_${date}/${REGION_NAME}_${fn_dst}_${date}
       mv tmp ./ingress_${REGION_NAME}/${REGION_NAME}_${fn_dst}_${date}
       #mv tmp ./ingress/${REGION_NAME}_${fn_dst}_${date}
   done < list

   ls ./${date}/*egress > list

   while read line; do
       fn_src=`echo $line`
       fn_dst=`echo $line | cut -d "/" -f 3`
       cat header > tmp
       cat ${fn_src} >> tmp
       echo "./egress/${REGION_NAME}_${fn_dst}_${date}"
       cp tmp ./egress_${REGION_NAME}_${date}/${REGION_NAME}_${fn_dst}_${date}
       mv tmp ./egress_${REGION_NAME}/${REGION_NAME}_${fn_dst}_${date}
       #mv tmp ./egress/${REGION_NAME}_${fn_dst}_${date}
   done < list

   rm -rf ${date}

   end_time=`date +%s`
   run_time=$((end_time - start_time))
   run_time_minutes=`echo $(( ${run_time} / 60))`

   echo "ELAPSED TIME:"${REGION_NAME}":"${date}":"$run_time":"$run_time_minutes

  if [ $date = $ENDDATE ] ; then
    break
  fi
 
  date=`date -d "$date 1day" "+%Y%m%d"`
done

