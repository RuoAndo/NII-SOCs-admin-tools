#!/bin/bash

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
if [ -f ${TABLE}_HIBETSU.csv ]; then
  echo ${TABLE}_HIBETSU.csv"が存在します。処理済みです。"
  exit
fi

OUTFILE=${TABLE}_HIBETSU.csv

awk -F, '{if($1==""){print $2","$3}else {print $1","$3}}' ${TABLE}_HIBETSU_*.csv > ${OUTFILE}_tmp

sort ${OUTFILE}_tmp | awk -F, 'NR==1{BK=$1;sum+=$2;}NR!=1{{if($1==BK){sum+=$2;}else {print BK":"sum; BK=$1; sum=$2;}}}END{print BK":"sum;}' > ${OUTFILE}

##############
# Terminate
##############
if [ ! -d ${TABLE} ]; then
  mkdir ${TABLE}
fi

mv ${TABLE}_HIBETSU_*.csv ${TABLE}
rm ${OUTFILE}_tmp

exit 0
