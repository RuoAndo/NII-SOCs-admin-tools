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

rm -rf all-dest_port
touch all-dest_port

rm -rf all-source_port
touch all-source_port

echo "timestamp, portNo, counted" >> all-dest_port
echo "timestamp, portNo, counted" >> all-source_port

for (( DATE=${START_DATE} ; ${DATE} <= ${END_DATE} ; DATE=`date -d "${DATE} 1 day" '+%Y%m%d'` )) ; do

  echo ${DATE}

  cp add-date-portNumber.py ${DATE}

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

  rm -rf tmp-source
  touch tmp-source

  rm -rf tmp-dest
  touch tmp-dest
  
  while read line; do
    echo "counting lines..."
    echo $line
    nLines=`wc -l ${line} | cut -d " " -f 1`
    echo $nLines

    echo "count dest port"
    time ./build.sh count_dest_port 
    ./count_dest_port ${line} $nLines
    cat dest_port >> tmp-dest

    echo "count source port"
    time ./build.sh count_source_port 
    ./count_source_port ${line} $nLines
    cat source_port >> tmp-source

  done < list-spl

  \cp tmp-dest dest_port
  \cp tmp-source source_port

  #####

  python add-date-portNumber.py dest_port ${DATE} >> ../all-dest_port
  python add-date-portNumber.py source_port ${DATE} >> ../all-source_port

  cd ..
done

nLines=`wc -l all-dest_port | cut -d " " -f 1`
./build.sh count_destPort_final 
./count_destPort_final all-dest_port $nLines
python add-date-portNumber.py destPort_final ${DATE} > tmp-destPort_final
cp tmp-destPort_final destPort_final-${START_DATE}-${END_DATE}
scp destPort_final-${START_DATE}-${END_DATE} 192.168.72.5:/mnt/sdc/splunk-session/$1

nLines=`wc -l all-source_port | cut -d " " -f 1`
./build.sh count_sourcePort_final
./count_sourcePort_final all-source_port $nLines
cp sourcePort_final sourcePort_final-${START_DATE}-${END_DATE}
scp sourcePort_final-${START_DATE}-${END_DATE} 192.168.72.5:/mnt/sdc/splunk-session/$1
