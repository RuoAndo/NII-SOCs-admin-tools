#!/bin/bash

if [ "$1" = "" ]
then
    echo "./add-date-subtype.sh DIR"
    exit 1
fi

start_time=`date +%s`

START_DATE=`date --date '3 day ago' +%Y%m%d`
END_DATE=`date --date '3 day ago' +%Y%m%d`

#START_DATE=$1
#END_DATE=$2

echo $START_DATE
echo $END_DATE

rm -rf all-subtype
touch all-subtype

echo "timestamp, subtype, counted" >> all-subtype

for (( DATE=${START_DATE} ; ${DATE} <= ${END_DATE} ; DATE=`date -d "${DATE} 1 day" '+%Y%m%d'` )) ; do

  echo ${DATE}

  cp add-date-subtype.py ${DATE}

  cp *.sh ${DATE}
  cp *.cpp ${DATE}
  cp *.h ${DATE}
  cp *.hpp ${DATE}

  cd ${DATE}

  #####

  echo "catting...."
  ./cat.sh
  
  echo "spliting..."
  split -l 100000000 all spl.

  ls spl.* > list-spl

  rm -rf tmp-subtype
  touch tmp-subtype
  
  while read line; do
    echo "counting lines..."
    echo $line
    nLines=`wc -l ${line} | cut -d " " -f 1`
    echo $nLines

    echo "count subtype"
    time ./build.sh count_subtype
    ./count_subtype ${line} $nLines
    cat subtype >> tmp-subtype

  done < list-spl

  # \cp tmp-dest dest_port
  # \cp tmp-source source_port

  #####

  python add-date-subtype.py tmp-subtype ${DATE} >> ../all-subtype

  cd ..
done

nLines=`wc -l all-subtype | cut -d " " -f 1`
./build.sh count_subtype_final
./count_subtype_final all-subtype $nLines
python add-date-subtype.py subtype_final ${START_DATE} > tmp-subtype_final
cp tmp-subtype_final subtype_final-${START_DATE}-${END_DATE}
scp subtype_final-${START_DATE}-${END_DATE} 192.168.72.5:/mnt/sdc/splunk-session/$1

end_time=`date +%s`
time=$((end_time - start_time))
echo "elapsed time:"$time
