#!/bin/bash

if [ "$1" = "" ]
then
    echo "./add-date-portNumber.sh DIR"
    exit 1
fi

START_DATE=`date --date '4 day ago' +%Y%m%d`
END_DATE=`date --date '4 day ago' +%Y%m%d`

#START_DATE=$1
#END_DATE=$2

rm -rf tmp-pair-ip-port
touch tmp-pair-ip-port

echo "timestamp, srcIP, srcPort, destIP, destPort, counted" >> tmp-pair-ip-port

for (( DATE=${START_DATE} ; ${DATE} <= ${END_DATE} ; DATE=`date -d "${DATE} 1 day" '+%Y%m%d'` )) ; do

  echo ${DATE}

  cp add-date-portNumber.py ${DATE}

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

  rm -rf tmp-pair-ip-port
  touch tmp-pair-ip-port

  #rm -rf tmp-dest
  #touch tmp-dest
  
  while read line; do
    echo "counting lines..."
    echo $line
    nLines=`wc -l ${line} | cut -d " " -f 1`
    echo $nLines

    echo "count dest port"
    time ./build.sh count_pair_ip_port
    ./count_pair_ip_port ${line} $nLines
    cat pair_ip_port >> tmp-pair-ip-port

  done < list-spl

  # \cp tmp-dest dest_port
  # \cp tmp-source source_port

  #####

  python add-date-pair-ip-port.py tmp-pair-ip-port ${DATE} >> ../all-pair-ip-port

  cd ..
done

nLines=`wc -l all-pair-ip-port | cut -d " " -f 1`
./build.sh count_pair_ip_port_final
./count_pair_ip_port_final all-pair-ip-port $nLines
cp pair_ip_port_final pair_ip_port_final-${START_DATE}-${END_DATE}
scp pair_ip_port_final-${START_DATE}-${END_DATE} 192.168.72.5:/mnt/sdc/splunk-session/$1

