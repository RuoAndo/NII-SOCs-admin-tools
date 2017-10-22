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
    echo "-- Usage:$0 対象月[yyyymm])" 
    echo "--------------------------------------------"
    exit 1
fi

TABLE=$1
if [ ${#TABLE} -ne 6 ]; then
    echo "--------------------------------------------"
    echo "-- Usage:$0 対象月[yyyymm])" 
    echo "--------------------------------------------"
    exit 1
fi

###############
# Exec
###############
OUT_FILE=${TABLE}.csv
# OUT FILE Check
if [ -f ${OUT_FILE} ]; then
    echo "結果ファイルが存在します。処理済です。"
    exit
fi

echo -n "大学ID,大学名," > head.csv

for file in `ls -1 ${TABLE}*_HIBETSU.csv`
do
  # create Header
  echo -n `echo ${file} | awk -F_ '{print $1}'` >> head.csv
  echo -n "," >> head.csv

  # OUT FILE Check
  if [ ! -f ${OUT_FILE} ]; then
      cp ${file} ${OUT_FILE}
      continue;
  fi

  # 完全外部結合（FULL OUTER JOIN)
  join -t: -a 1 -a 2 -1 1 -2 1 ${OUT_FILE} ${file}  > ${OUT_FILE}.tmp
  
  mv ${OUT_FILE}.tmp ${OUT_FILE}

done

##############
# Terminate
##############

cat ${OUT_FILE} | tr ":" "," > ${OUT_FILE}.tmp
mv ${OUT_FILE}.tmp ${OUT_FILE}

# Get University Info
psql -t -q -f template_university.sql -A -F, > university.csv

# JOIN University Info
join -t, -1 1 -2 1 university.csv ${OUT_FILE} > ${OUT_FILE}.tmp
cat head.csv > ${OUT_FILE}
echo "" >> ${OUT_FILE}
cat ${OUT_FILE}.tmp >> ${OUT_FILE}

rm ${OUT_FILE}.tmp
rm head.csv
rm university.csv

exit 0
