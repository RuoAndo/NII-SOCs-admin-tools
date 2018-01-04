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
if [ $# -ne 2 ]; then
    echo "--------------------------------------------"
    echo "-- Usage:$0 対象日[yyyymmdd] 間隔(30|300|3600)" 
    echo "--------------------------------------------"
    exit 1
fi

TABLE=$1
if [ ${#TABLE} -ne 8 ]; then
    echo "--------------------------------------------"
    echo "-- Usage:$0 対象日[yyyymmdd] 間隔(30|300|3600)" 
    echo "--------------------------------------------"
    exit 1
fi

INTERVAL=$2
if [ ${INTERVAL} -ne 30 -a ${INTERVAL} -ne 300 -a ${INTERVAL} -ne 3600 ]; then
    echo "--------------------------------------------"
    echo "-- Usage:$0 対象日[yyyymmdd] 間隔(30|300|3600)" 
    echo "--------------------------------------------"
    exit 1
fi

# START
echo "== 処理開始: "`date +"%Y/%m/%d %H:%M:%S"`" =="

###############
# Exec
###############

# GET DATA START
echo "  1.DB取得開始: "`date +"%Y/%m/%d %H:%M:%S"`

# DATE_FROM
DATE_FROM="${TABLE} 00:00:00"

# DATE_TO
DATE_TO="${TABLE} 23:59:59"

# Unix Time
CALC_DATE_FROM=`date --date "${DATE_FROM}" +%s`
CALC_DATE_TO=`date --date "${DATE_TO}" +%s`

# Calucuration Interval Mituts
INT_SEC=`expr \( ${CALC_DATE_TO} - ${CALC_DATE_FROM} \)`

# Calucuration Cycle Time
CYCLE=$(((INT_SEC)/${INTERVAL}))

if [ $(((INT_SEC)%${INTERVAL})) -ne 0 ]; then
  CYCLE=$(((CYCLE)+1))
fi

SEL_DATE_FROM=`date +"%Y/%m/%d %H:%M:%S" -d "${DATE_FROM}"`
SEL_DATE_TO=`date +"%Y/%m/%d %H:%M:%S" -d "${DATE_FROM} ${INTERVAL} second"`

for((j=1;j<=${CYCLE};j++));
do
  # Create OUTFILE NAME
  FILENAME_DATE_FROM=`date +"%H:%M:%S" -d "${SEL_DATE_FROM}"`
  FILENAME_DATE_TO=`date +"%H:%M:%S" -d "${SEL_DATE_TO}"`
  OUT_FILE_NAME=${TABLE}_HIBETSU_${j}_${FILENAME_DATE_FROM}-${FILENAME_DATE_TO}.csv

  # Main Exec
  cat template_PaloAlto.sql > selectTMP_$$.sql
  echo -n "where capture_time >= '" >> selectTMP_$$.sql
  echo -n ${SEL_DATE_FROM} >> selectTMP_$$.sql
  echo -n "' and capture_time < '" >> selectTMP_$$.sql
  echo -n ${SEL_DATE_TO} >> selectTMP_$$.sql
  echo "' " >> selectTMP_$$.sql
  echo -n "GROUP by alarm_name order by 1" >> selectTMP_$$.sql
  echo ";" >> selectTMP_$$.sql

  psql -t -q -f selectTMP_$$.sql -A -F, > ${OUT_FILE_NAME}

  SEL_DATE_FROM=`date +"%Y/%m/%d %H:%M:%S" -d "${SEL_DATE_FROM}  ${INTERVAL} second"`
  SEL_DATE_TO=`date +"%Y/%m/%d %H:%M:%S" -d "${SEL_DATE_TO}  ${INTERVAL} second"`

done

# GET DATAT END
echo "  1.DB取得終了: "`date +"%Y/%m/%d %H:%M:%S"`

##############
# Terminate
##############
if [ -d ${TABLE}_${INTERVAL} ]; then
  \rm -r ${TABLE}_${INTERVAL}
fi

mkdir ${TABLE}_${INTERVAL}

mv ${TABLE}_HIBETSU_*.csv ${TABLE}_${INTERVAL}

rm selectTMP_$$.sql

##############
# Terminate
##############

./edit_HIBETSU_AlarmEach_PaloAlto.sh ${TABLE} ${INTERVAL}

# END
echo "== 処理終了: "`date +"%Y/%m/%d %H:%M:%S"`" =="

exit 0
