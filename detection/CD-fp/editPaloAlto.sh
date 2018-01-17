#!/bin/bash

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

# AGREGATE START
echo "  2.集計処理開始: "`date +"%Y/%m/%d %H:%M:%S"`

###############
# Exec
###############
OUT_FILE=${TABLE}_${INTERVAL}.csv
# OUT FILE Check
if [ -f ${OUT_FILE} ]; then
    echo "結果ファイルが存在します。処理済です。"
    exit
fi

cd ./${TABLE}_${INTERVAL}

# Aggregate
i=1
echo -n "Time/Alarm," > head.csv
for file in `ls -v ${TABLE}*_HIBETSU*.csv`
do
  
  # header
  head=`echo -n ${file} | awk -F_ '{print $4}' |awk -F- '{print $1}'`
  echo -n ${head}"," >> head.csv
  
  # OUT FILE Check
  if [ ! -f ${OUT_FILE} ]; then
      cp ${file} ${OUT_FILE}
      continue;
  fi

  let ++i
  array=("${array[@]}" ${i})
  
  # FULL OUTER JOIN
  if [ ${i} -eq 2 ]; then
    join -t, -a 1 -a 2 -1 1 -2 1 -o 0 1.2 2.2 -e "0" ${OUT_FILE} ${file}  > ${OUT_FILE}.tmp
  else
    str="$(IFS=,; echo "${array[*]}")"
    script="join -t, -a 1 -a 2 -1 1 -2 1 -o 0 1.{${str}} 2.2 -e "0" ${OUT_FILE} ${file}  > ${OUT_FILE}.tmp"
    eval ${script}
  fi
  
  mv ${OUT_FILE}.tmp ${OUT_FILE}

done

##############
# Terminate
##############
cat head.csv > ${OUT_FILE}.tmp
echo "" >> ${OUT_FILE}.tmp
cat ${OUT_FILE} >> ${OUT_FILE}.tmp

# Replacement
awk -F, '
  { for (i=1; i<=NF; i++)  { a[NR,i] = $i } } NF>p { p = NF }
  END {
  for(j=1; j<=p; j++) { str=a[1,j]; for(i=2; i<=NR; i++){ str=str","a[i,j]; }
  print str
  }
  }' ${OUT_FILE}.tmp | sed '/^,*$/d' > ${OUT_FILE}


# Average
for((j=1;j<=`awk -F, '{print NF}' ${OUT_FILE} | uniq`;j++));
do

  if [ ${j} -eq 1 ]; then
    echo -n "Average," >> average.csv.tmp
  else
    average=`awk -F, '{m+=$'"$j"'} END{print m/NR;}' ${OUT_FILE}`
    echo -n ${average}"," >> average.csv.tmp
  fi

done

sed -e 's/,$//' average.csv.tmp > average.csv

cat average.csv >> ${OUT_FILE}

mv ${OUT_FILE} ../

##############
# Terminate
##############

rm head.csv ${OUT_FILE}.tmp average.csv average.csv.tmp

# AGREGATE END
echo "  2.集計処理終了: "`date +"%Y/%m/%d %H:%M:%S"`

exit 0
