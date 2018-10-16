#!/bin/bash

if [ "$1" = "" ]
then
    echo "./add-date-application.sh DIR"
    exit 1
fi

START_DATE=`date --date '3 day ago' +%Y%m%d`
END_DATE=`date --date '3 day ago' +%Y%m%d`

#START_DATE=$1
#END_DATE=$2

rm -rf all-application
touch all-application

echo "timestamp, application, counted" >> all-application

for (( DATE=${START_DATE} ; ${DATE} <= ${END_DATE} ; DATE=`date -d "${DATE} 1 day" '+%Y%m%d'` )) ; do

  echo ${DATE}

  cp add-date-application.py ${DATE}

  cp *.sh ${DATE}
  cp *.cpp ${DATE}
  cp *.h ${DATE}
  cp *.hpp ${DATE}
  cp *.py ${DATE}

  cd ${DATE}

  #####

  echo "catting...."
  ./cat.sh
  
  echo "spliting..."
  split -l 100000000 all spl.

  ls spl.* > list-spl

  rm -rf tmp-application
  touch tmp-application
  
  while read line; do
    echo "counting lines..."
    echo $line
    nLines=`wc -l ${line} | cut -d " " -f 1`
    echo $nLines

    echo "count application"
    time ./build.sh count_application
    ./count_application ${line} $nLines
    cat application >> tmp-application

  done < list-spl

  # \cp tmp-dest dest_port
  # \cp tmp-source source_port

  #####

  python add-date-application.py tmp-application ${DATE} >> ../all-application

  cd ..
done

nLines=`wc -l all-application | cut -d " " -f 1`
./build.sh count_application_final
./count_application_final all-application $nLines

#TMP_DATE=`date --date '4 day ago' +%Y%m%d`
#python add-date-application.py application_final ${TMP_DATE} > tmp-application_final

python add-date-application.py application_final ${START_DATE} > tmp-application_final
cp tmp-application_final application_final-${START_DATE}-${END_DATE}
scp application_final-${START_DATE}-${END_DATE} 192.168.72.5:/mnt/sdc/splunk-session/$1

