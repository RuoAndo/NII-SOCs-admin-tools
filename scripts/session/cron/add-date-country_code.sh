#!/bin/bash

if [ "$1" = "" ]
then
    echo "./add-date-portNumber.sh DIR"
    exit 1
fi

START_DATE=`date --date '3 day ago' +%Y%m%d`
END_DATE=`date --date '3 day ago' +%Y%m%d`

#START_DATE=$1
#END_DATE=$2

rm -rf all-dest_country_code
touch all-dest_country_code

#rm -rf all-source_country_code
#touch all-source_country_code

echo "timestamp, country_code, counted" >> all-dest-country_code
#echo "timestamp, country_code, counted" >> all-country_code

for (( DATE=${START_DATE} ; ${DATE} <= ${END_DATE} ; DATE=`date -d "${DATE} 1 day" '+%Y%m%d'` )) ; do

  echo ${DATE}

  cp add-date-country_code.py ${DATE}

  cp *.sh ${DATE}
  cp *.cpp ${DATE}
  cp *.h ${DATE}
  cp *.hpp ${DATE}
  cp *.py ${DATE}

  cd ${DATE}

  #####

  #echo "catting...."
  #./cat.sh
  
  echo "spliting..."

  split -l 100000000 all spl.
  ls spl.* > list-spl

  rm -rf tmp-dest_country_code
  touch tmp-dest_country_code

  rm -rf tmp-source_country_code
  touch tmp-source_country_code
  
  while read line; do
    echo "counting lines..."
    echo $line
    nLines=`wc -l ${line} | cut -d " " -f 1`
    echo $nLines

    # ofstream outputfile("dest_country_code"); 
    echo "count dest country_code"
    time ./build.sh count_dest_country_code 
    ./count_dest_country_code ${line} $nLines
    cat dest_country_code >> tmp-dest-country_code

    echo "count source country_code"
    time ./build.sh count_source_country_code
    ./count_source_country_code ${line} $nLines
    cat dest_country_code >> tmp-source-country_code

  done < list-spl

  #\cp tmp-dest-country_code dest_country
  #\cp tmp-source source_port

  #####

  python add-date-country_code.py tmp-dest-country_code ${DATE} >> ../all-dest_country_code
  python add-date-country_code.py tmp-source-country_code ${DATE} >> ../all-source_country_code

  cd ..
done

nLines=`wc -l all-dest_country_code | cut -d " " -f 1`
./build.sh count_dest_country_code_final 
./count_dest_country_code_final all-dest_country_code $nLines
python add-date-country_code.py dest_country_code_final ${DATE} > tmp-dest_country_code_final
cp tmp-dest_country_code_final dest_country_code_final-${START_DATE}-${END_DATE}
scp dest_country_code_final-${START_DATE}-${END_DATE} 192.168.72.5:/mnt/sdc/splunk-session/$1

nLines=`wc -l all-source_country_code | cut -d " " -f 1`
./build.sh count_source_country_code_final 
./count_source_country_code_final all-source_country_code $nLines
python add-date-country_code.py source_country_code_final ${DATE} > tmp-source_country_code_final
cp tmp-source_country_code_final source_country_code_final-${START_DATE}-${END_DATE}
scp source_country_code_final-${START_DATE}-${END_DATE} 192.168.72.5:/mnt/sdc/splunk-session/$1


