#!/bin/bash

##############
# Init
###############

export PGHOST=192.168.72.2
export PGPORT=5432
export PGDATABASE=attack_data_analysis
export PGUSER=niiada_rdb
export PGPASSWORD=yOw8@WCv7

####################################
### Param Check
####################################
if [ $# -ne 1 ]; then
    echo "--------------------------------------------"
    echo "-- Usage:$0 対象日[yyyymmdd])" 
    echo "--------------------------------------------"
    exit 1
fi

TABLE=$1
if [ ${#TABLE} -ne 8 ]; then
    echo "--------------------------------------------"
    echo "-- Usage:$0 対象日[yyyymmdd])" 
    echo "--------------------------------------------"
    exit 1
fi


###############
# Exec
###############

# DATE_FROM
cat template_min.sql | sed -e "s/YYYYMMDD/${TABLE}/g" > selectTMP_$$.sql
DATE_FROM=`psql -t -q -f selectTMP_$$.sql -A -F,`

# DATE_TO
cat template_max.sql | sed -e "s/YYYYMMDD/${TABLE}/g" > selectTMP_$$.sql
DATE_TO=`psql -t -q -f selectTMP_$$.sql -A -F,`

# Unix Time
CALC_DATE_FROM=`date --date "${DATE_FROM}" +%s`
CALC_DATE_TO=`date --date "${DATE_TO}" +%s`

# Calucuration Interval Mituts
INT_MIN=`expr \( ${CALC_DATE_TO} - ${CALC_DATE_FROM} \) / 60`

# Calucuration Cycle Time
CYCLE=$(((INT_MIN)/5))

if [ $(((INT_MIN)%5)) -ne 0 ]; then
  CYCLE=$(((CYCLE)+1))
fi

SEL_DATE_FROM=`date +"%Y/%m/%d %H:%M:%S" -d "${DATE_FROM}"`
SEL_DATE_TO=`date +"%Y/%m/%d %H:%M:%S" -d "${DATE_FROM} 5 minutes"`

for((j=1;j<=${CYCLE};j++));
do
  # Create OUTFILE NAME
  FILENAME_DATE_FROM=`date +"%H:%M:%S" -d "${SEL_DATE_FROM}"`
  FILENAME_DATE_TO=`date +"%H:%M:%S" -d "${SEL_DATE_TO}"`
  OUT_FILE_NAME=${TABLE}_HIBETSU_${j}_${FILENAME_DATE_FROM}-${FILENAME_DATE_TO}.csv

  # Main Exec
  cat template.sql | sed -e "s/YYYYMMDD/${TABLE}/g" > selectTMP_$$.sql
  echo -n "where capture_time >= '" >> selectTMP_$$.sql
  echo -n ${SEL_DATE_FROM} >> selectTMP_$$.sql
  echo -n "' and capture_time < '" >> selectTMP_$$.sql
  echo -n ${SEL_DATE_TO} >> selectTMP_$$.sql
  echo "' " >> selectTMP_$$.sql
  echo -n "GROUP by src_university_id,dest_university_id" >> selectTMP_$$.sql
  echo ";" >> selectTMP_$$.sql

  psql -t -q -f selectTMP_$$.sql -A -F, > ${OUT_FILE_NAME}

  SEL_DATE_FROM=`date +"%Y/%m/%d %H:%M:%S" -d "${SEL_DATE_FROM}  5 minutes"`
  SEL_DATE_TO=`date +"%Y/%m/%d %H:%M:%S" -d "${SEL_DATE_TO}  5 minutes"`

done

##############
# Terminate
##############

./sum_HIBETSU.sh ${TABLE}

rm selectTMP_$$.sql

exit 0
